---
title: Using 'ab', ApacheBench to test Web Server Performance
published: 2009-04-05 08:00:00 +0000
tags: 
---

<p>ApacheBench (referred to as 'ab' in the terminal) is a tool for testing web server performance by allowing you to test how long a set of requests per second the web server is capable of serving. </p>

<p>Whilst this does not reflect a model of real world usage, it can aid in the tweaking and performance improvement of the Web Server itself.</p>

<p>This tool is of course aimed at testing Apache servers, however it can be used on others.</p>

<h2>Usage</h2>

<p>Usage is rather simple. At it's core, the amount of requests to complete and the url to test are required. On top of this you may inform the application to carry out more than one request at a time, as show in the second example.</p>

<pre LANG="Bash">
   $ ab -n 100 http://domain/

   $ ab -n 100  -c 3 http://domain/
</pre>

<p>When this is run the specified web page is downloaded and the time taken for it to happen is measured.</p>

<h2>Some Results</h2>

<p>These are the results I gained from running this against the server behind this, testing using 3 concurrent connections and 100 requests.</p>

<pre lang="Bash">
$ ab -n 100 -c 3 http://nickcharlton.net/
This is ApacheBench, Version 2.3 <$Revision: 655654 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking nickcharlton.net (be patient).....done


Server Software:        Apache/2.2.3
Server Hostname:        nickcharlton.net
Server Port:            80

Document Path:          /
Document Length:        34350 bytes

Concurrency Level:      3
Time taken for tests:   13.371 seconds
Complete requests:      100
Failed requests:        0
Write errors:           0
Total transferred:      3471900 bytes
HTML transferred:       3435000 bytes
Requests per second:    7.48 [#/sec] (mean)
Time per request:       401.120 [ms] (mean)
Time per request:       133.707 [ms] (mean, across all concurrent requests)
Transfer rate:          253.58 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:       27  135 160.8     87    1295
Processing:    65  257 562.0    140    5108
Waiting:       31  149 169.3    105    1297
Total:        104  392 617.4    254    5483

Percentage of the requests served within a certain time (ms)
  50%    254
  66%    317
  75%    348
  80%    510
  90%    776
  95%    920
  98%   2311
  99%   5483
 100%   5483 (longest request)
</pre>

<h2>Limitations</h2>

<p>ApacheBench does not however give you a figure to suggest how many requests a server may complete, or reflect the usage which will be shown with a real set of users. This is because any given page or application may consist of many requests</p>

<h2>What to do with the Results?</h2>

<p>The results which you gain are specifically useful in tweaking settings regarding the web server itself. Whilst ApacheBench cannot directly tell you what needs tweaking, once you start changing settings you can realise what is best for your server.</p>

<p><em>My thanks go out to <a href="http://blog.init.hr/">Ante</a> for helping me improve this post, clearing up mistakes and ensuring that the right information was being given. This post has been slightly edited since it's original posting.</em></p>

