---
title: Ruby Subprocesses with stdout and stderr Streams
published: 2014-01-08T16:03:00Z
tags: ruby, posix, boxes
---

I've been doing a few things with Ruby which involve controlling and responding to
long-running processes, where the Ruby-based 'wrapper' takes the task of automating
something which is otherwise quite complex. Perhaps the best example is [boxes][],
which uses a collection of [Rake][] tasks to generate [Vagrant][] boxes using
[Packer][] –– each build takes somewhere in the region of twenty minutes to complete.

But, I wanted to be able to more closely control the output (hiding much of it from
view) and react to events like build failures, which wasn't possible by using
[`system()`][system]. This needed to be able to handle the output as it came line 
by line without blocking (handling them as a stream), be able to handle `stdout` 
and `stderr` independently, and allow me to collect all of the output from a 
subprocess (for providing as a sort-of stack trace).

I went through many different solutions (using [`Open3.popen3`][popen], [`PTY`][PTY] 
and others), before coming across this hybrid solution using `popen3` and separate 
threads for each output stream in [this Stack Overflow post][so] which met most of 
my requirements.

This gave me a basic solution which looks like this:

```ruby
require 'open3'

cmd = './packer_mock.sh'
data = {:out => [], :err => []}

# see: http://stackoverflow.com/a/1162850/83386
Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
  # read each stream from a new thread
  { :out => stdout, :err => stderr }.each do |key, stream|
    Thread.new do
      until (raw_line = stream.gets).nil? do
        parsed_line = Hash[:timestamp => Time.now, :line => "#{raw_line}"]
        # append new lines
        data[key].push parsed_line
        
        puts "#{key}: #{parsed_line}"
      end
    end
  end

  thread.join # don't exit until the external process is done
end
```

Line 3 pecifies the command that will be run. This is just a shell script which 
prints a multitude of characters for testing. Line 4 defines the final data 
structure; a `Hash` with two `Array`s for `stdout` and `stderr`.

The next interesting bits are Lines 9 and 10 which create a [`Thread`][thread] for 
handling the `stdout` and `stderr` streams seperately. Inside this the `until` 
block reads from the given stream, structures it and stores it. I'm adding a 
[`Time`][time] object here to aid my presentation of it later.

Line 16 would be replaced by a conditional depending on the amount of verbosity the
user desired. Finally, Line 21 joins the thread once it has finished executing.

This, then, allows me to continue handling long processes as a stream, but handle
each line individually. But the interface is a little awkward to use. Providing a
simpler command a single block could simplify this, something like:

```ruby
Utils::Subprocess.new './packer_mock.sh' do |stdout, stderr, thread|
  puts "stdout: #{stdout}" # => "simple output"
  puts "stderr: #{stderr}" # => "error: an error happened"
  puts "pid: #{thread.pid}" # => 12345
end
```

Which could be implemented like this rather impressively nested bit of code:

```ruby
require 'open3'

module Utils
  class Subprocess
    def initialize(cmd, &block)
      # see: http://stackoverflow.com/a/1162850/83386
      Open3.popen3(cmd) do |stdin, stdout, stderr, thread|
        # read each stream from a new thread
        { :out => stdout, :err => stderr }.each do |key, stream|
          Thread.new do
            until (line = stream.gets).nil? do
              # yield the block depending on the stream
              if key == :out
                yield line, nil, thread if block_given?
              else
                yield nil, line, thread if block_given?
              end
            end
          end
        end

        thread.join # don't exit until the external process is done
      end
    end
  end
end
```

Unlike the first approach, this just passes back the lines as strings which is `nil`
if there's no value. The final argument to the block is the [thread][] the subprocess 
is run as. `thread.pid` will give the [PID][].

For now, this works pretty well for [boxes][] and will allow me to throw it into
something like [Jenkins][] without a ridiculous amount of logs to parse to see which
ones build successfully.

[boxes]: https://github.com/nickcharlton/boxes
[Rake]: http://rake.rubyforge.org
[Vagrant]: http://vagrantup.com
[Packer]: http://packer.io
[system]: http://ruby-doc.org/core-2.1.0/Kernel.html#method-i-system
[popen]: http://www.ruby-doc.org/stdlib-2.1.0/libdoc/open3/rdoc/Open3.html
[PTY]: http://ruby-doc.org/stdlib-2.1.0/libdoc/pty/rdoc/PTY.html
[so]: http://stackoverflow.com/a/1162850/83386
[time]: http://www.ruby-doc.org/core-2.1.0/Time.html
[thread]: http://ruby-doc.org/core-2.1.0/Thread.html
[PID]: http://en.wikipedia.org/wiki/Process_identifier
[Jenkins]: http://en.wikipedia.org/wiki/Jenkins_(software)

