---
title: Test Environments with Vagrant and Chef
published: 2013-04-04 00:46:00 +0000
tags: vagrant, chef, programming
---

I recently completed a project for an assignment which had a mess of dependencies.
It depends upon [libgit2][] and [pygit2][], both of which are a complete pain to 
get working. After it blew up in my face for the third time, I realised I was being 
silly and should go back to using [Vagrant][], and along with it, the configuration 
management tool, [Chef][]. 

Why Chef, over it's main competitor, [Puppet][]? I like it more. But I can't really
describe why. I'm like that sometimes. I wish it were because one had much nicer,
more accessable documentation, but neither seems to be the case. Fortunately,
Vagrant has lovely documentation and so I'm not going to replicate it. I am going
to go into detail about how to use both together and provide an introduction to Chef,
though.

Vagrant allows you to start, stop and destroy virtual machines in a nice abstraction
which also provides hooks to automate the provisioning of them. I want to be able to
quickly spin up a test environment per project and when it's started I want everything
configured for me, [dotfiles][], libraries, applications, shared folders and so on. 

Chef handles the second bit. It's known as a configuration management tool. It
describes what we want the system to look like after it's run, but we don't care
about how we get there. Chef overuses the cooking analogy a bit, but: A recipe 
describes the way a specific tool is configured, along with any dependencies. A 
cookbook contains the recipes we wish to run on a system. I'm mostly going to talk
about using "Chef Solo", that is, Chef without a server as that works best for
environments which are quickly created, used and thrown away.

### Before You Begin

Firstly, you should install:

* [VirtualBox][]
* [Vagrant][]

Then you should at least skim read the [Vagrant documentation][]. I'll only describe
it lightly. By the end, I'll have a "[test-environment][]" repository which I'll clone
whenever I need a new to spin something up.

### Virtual Machines with Vagrant

Vagrant is the glue that holds all of this together and makes interacting with
virtual machines as pleasurable as possible. It uses a simple Ruby DSL[^ruby] to
describe the virtual machines that should be managed. All of this is stored in a
`Vagrantfile`.

Vagrant uses the notion of "boxes" to describe preconfigured base VMs for which we
can work from. I'm using Ubuntu here. You should also look at [Gareth Rushgrove][]'s
[Vagrant Boxes][] site. A simple Vagrant friendly install with a copy of Chef is
all you need.

Firstly, create a Vagrantfile and, if you don't have one already, grab a box:

```sh
vagrant init
vagrant box add precise32 \ http://files.vagrantup.com/precise32.box
```

Then start the Vagrantfile (it already has an example configuration, but I prefer it
a little tidier):

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "precise32"
end
```

Now, you can start the virtual machine and ssh into it:

```sh
vagrant up
vagrant ssh
```

And, you can throw the box away by running:

```sh
vagrant destroy
```

This might be the bit where you wish you had an SSD, if you don't already have one. 
You'll do that a lot. This base box configures Ruby, Chef and a few other things for 
us. And notably it'll share the working directory in which the Vagrantfile is 
contained. You should now be good to start thinking about provisioning.

### Provisioning with Chef

There are a few versions of Chef. These can be broadly split into "client", known as
"Solo" and "client-server", in the case of "Chef Server", "Chef Hosted" or "Chef
Private". These latter three provide a central area in which to manage nodes, 
cookbooks, roles and so on. 

The node is a server (actually, it's not necessarily a server, because you could 
use Chef to manage your workstation too) that is managed by Chef. The routine to
complete a task is known as a recipe. This is used to install, configure and start
services, from the appropriate package management system, or from source and using
the correct dependencies. These recipes are grouped together in a "cookbook".

A set of cookbooks may be configured together so that a node can have a "role"
applied to it. This is something like "web" or "database", causing Chef to configure 
the appropriate cookbooks for it.

"Data Bags" are collections of data (which may be encrypted) which are used by Chef
to aid the install. The idea here is that the data can be kept seperate from the
configuration, like usernames, passwords or keys. Below, I'm using this to put a
special set of `ssh` keys in place so I can push code up to GitHub inside the test
environment.

One of the few key points to Chef, and similar configuration management tools is 
that of "idempotence" &mdash; every time Chef is run, the same state will be had 
at the end. So, for example if you run Chef manually and everything is configured, 
nothing will happen. If you destroy this virtual machine and create another, once
Chef has done it's thing, it'll be exactly the same as the old one was.

`knife` is Chef's main client side tool for interacting with all of this. Whilst it's
designed to be used to interact with the Chef Server, it can also be used locally
to assemble cookbooks. Once you hunt around, you'll also see that `knife` has plugins
available to interact with [EC2][], [OpenStack][] and [many others][knifeplugins].

_I'm missing a bunch of stuff out here because I'm only interested in using Chef with 
Vagrant. Look at the "Further Reading" heading at the bottom._

#### Building Cookbooks

Cookbooks look a little bit like this (with each indent being a subdirectory):

```
cookbooks
    cookbook-name
        recipes
            default.rb
```

The root `cookbooks` represents the default collection of cookbooks that Chef &mdash;
and especially when used with Vagrant &mdash; looks for. Inside here are the cookbooks
themselves. A single cookbook can contain multiple recipes, but the one that is
called by default is funnily enough, called, `default.rb`.

A cookbook is then used to describe the tool which needs installing, for example,
`git`. Our cookbook would be called "git" and our `default.rb` recipe might look 
like this:

```ruby
package "git"
```

This will ensure that the package from the local package management system, "git" is
installed.

Of course, that doesn't necessarily exist on every system's package manager. Chef
has a library called "[Ohai][]" that sniffs out the node and reports what it is and 
what it can do. And to interact with Ohai, Chef's DSL provides methods like 
`value_for_platform`.

You might wish to use Opscode's '[chef-repo][]', but I'd prefer to build this up
myself, at least for now. It is all about learning it, afterall. The same applies
for using `knife`, which I mentioned before. This can be used to create a cookbook's
file structure for you.

Opscode, and the community maintain a collection of cookbooks that you can use.
A lot of these include tested support for lots of different OS styles and Linux
distributions. So you'll probably often find you might wish to lean towards these.
Opscode have a [community page for shared Cookbooks][cookbooks]. And an organisation
on GitHub containing all of the [ones which they manage themselves][cookbookrepo].
I'll use some of these later as submodules.

#### Vagrant Integration

Vagrant supports configuring Chef from inside the Vagrantfile. Typically, you'd
define a `node.json` file. This would contain the "run list" &mdash; the list of
recipes that a node should manage. Vagrant handles writing, and copying over the VM
this `node.json` file for you on `vagrant up` or on `vagrant reload`. You can also 
assign roles, add recipes or assign a "data bag" that should be used. The 
configuration for the `git` cookbook above should look something like this:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "precise32"

  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "git"
  end
end
```

This will ensure Chef Solo is invoked when you start up your Vagrant VM, adding "git"
to it's run list.

#### A Cookbook for `dotfiles`

That's all well and good. But, a more complex worked example is more useful. I want
to be able to run a `git clone` on my [dotfiles][] and then run the included 
`setup.sh` script, but before I do this, I need to also ensure that all of it's 
dependencies (and the tools I expect) are installed. On top of this, I want a set of
keys copied over so that I can access the likes of GitHub and so forth.

To do this, I'll create a cookbook called `dotfiles` which is tasked with installing
the client utilities I expect (git, vim, tmux). Followed by configuring the keys.
After this, it will pul down a clone of my dotfiles and running it's `setup.sh` 
script.

But before this is installed, I'll run a few more recipes which install the system 
libraries and build environment. Then we'll end up with a Vagrantfile which looks 
something like this:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "precise32"

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      "dotfiles" => {
        "user" => "vagrant",
        "group" => "vagrant",
        "public_key" => IO.read(File.expand_path("~/.ssh/id_rsa.pub")),
        "private_key" => IO.read(File.expand_path("~/.ssh/id_rsa"))
      }
    }

    chef.add_recipe "build-essential"
    chef.add_recipe "python"
    chef.add_recipe "dotfiles"
  end
end
```

The recipes will be installed in the same order as they are listed here. The
`chef.json` call passes along a data bag. This is used to provide the target user
(Chef is run as root, and I probably won't always want to be using my `dotfiles`
cookbook like this) and to pass along my own public/private key pair[^keys], by
using a quick one-liner to suck up the file and pass it along as a string.

In the `dotfiles` cookbook, `default.rb` looks like this:

```ruby
# tools
%w(git vim vim-scripts tmux).each do |pkg|
  package pkg
end

home_dir = "/home/#{node['dotfiles']['user']}"

# setup ssh keys
file "#{home_dir}/.ssh/id_rsa" do
  owner node['dotfiles']['user']
  group node['dotfiles']['group']
  mode "0600"
  content node['dotfiles']['private_key']
  action :create
end

file "#{home_dir}/.ssh/id_rsa.pub" do
  owner node['dotfiles']['user']
  group node['dotfiles']['group']
  mode "0600"
  content node['dotfiles']['public_key']
  action :create
end

# sync dotfiles
git "#{home_dir}/dotfiles" do
  repository "git://github.com/nickcharlton/dotfiles.git"
  reference "master"
  enable_submodules true
  user node['dotfiles']['user']
  group node['dotfiles']['group']
  action :checkout
end

# setup dotfiles
bash "setup_dotfiles" do
  cwd "#{home_dir}/dotfiles"
  user node['dotfiles']['user']
  group node['dotfiles']['group']
  environment "HOME" => home_dir
  code "./setup.sh"
end
```

You can use a Ruby whitespace array (the `%w()` bit) to iterate around a list of
packages, and pass that to the `package` method. This works fine for me, as I'm only
going to use Debian/Ubuntu. Then, we create the ssh key files, by using the values
from the data bag.

For the last bit, we clone a copy of my `dotfiles` repo (including it's multiple
submodules) and run the setup script. The environment variable of `$HOME` specifies
where the user's home directory, so we override this so that the script can handle
being run by root.

The process of setting up a new environment is now a matter of cloning the
"[test-environment][]" repository, then running `vagrant up`. On my 2009 MacBook Pro,
on a crappy DSL connection (there's a few packages to grab) this takes just under
5 minutes, but without grabbing the packages, the Chef run only takes 30 seconds of
that. With a good connection (or a local `apt-cache`) and something a bit faster
than this machine you could cut that down quite a bit.

### Further Reading

This is just enough Chef to setup a basic Debian/Ubuntu environment for the way I
like things, but this should put you in enough of a position to understand the basic
concepts. So the next step would be to jump over to the main [Chef documentation][].
It's quite readable once you understand the basics.

[libgit2]: http://libgit2.github.com/
[pygit2]: http://www.pygit2.org/
[Vagrant]: http://www.vagrantup.com/
[Chef]: http://www.opscode.com/
[Puppet]: https://puppetlabs.com/
[dotfiles]: https://github.com/nickcharlton/dotfiles
[VirtualBox]: https://www.virtualbox.org/
[Vagrant documentation]: http://docs.vagrantup.com/
[test-environment]: https://github.com/nickcharlton/test-environment
[Gareth Rushgrove]: http://www.morethanseven.net/
[Vagrant Boxes]: http://vagrantbox.es/
[chef-repo]: https://github.com/opscode/chef-repo/
[EC2]: http://docs.opscode.com/plugin_knife_ec2.html
[OpenStack]: http://docs.opscode.com/plugin_knife_openstack.html
[knifeplugins]: http://docs.opscode.com/plugin_knife.html
[cookbooks]: http://community.opscode.com/cookbooks
[Ohai]: http://docs.opscode.com/ohai.html
[cookbookrepo]: https://github.com/opscode-cookbooks/
[Chef documentation]: http://docs.opscode.com

[^ruby]: You don't really need to know all that much Ruby to get working with 
    Vagrant or Chef. But I would recommend at least knowing the basics of the 
    syntax.

[^keys]: I should really be using a seperate key pair here, but that easy enough
    to change.

