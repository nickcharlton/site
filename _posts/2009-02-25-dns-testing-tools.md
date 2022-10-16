---
title: DNS Testing Tools
tags: 
---

<p>When working with DNS, it can be a painful experience. From the time it takes for the root servers to update with your new records to simple mistakes made when working with large zone files. Here I explain six tools which can help route out DNS problems using the terminal. All of these work out of the box on OSX. </p>

<h2>nslookup</h2>

<p>nslookup is used to pull up the basic information associated with a domain.  Using nslookup is as simple as providing the following arguments:</p>

<pre lang="Bash">$ nslookup nickcharlton.org.uk</pre>

<p>A likely response could be similar to the following: </p>

<pre lang="Bash">Server:		208.67.222.222
Address:	208.67.222.222#53

Non-authoritative answer:
Name:	nickcharlton.org.uk
Address: 78.86.198.208</pre>

<p>This response tells you the nameserver which was queried, in this case one of those of OpenDNS which I use at home and the response from the name server when it was queried. The last IP is that of my server.</p>

<h2>dig</h2>

<p>Dig is a most useful tool, it officially stands for Domain Information Gopher and allows you to pull the data from the name server just as your machine would in taking a request. This allows you to pull the public records for the domain.</p>

<pre lang="Bash">$ dig nickcharlton.org.uk</pre>

<pre lang="Bash">
<<>> DiG 9.4.2-P2 <<>> nickcharlton.org.uk
;; global options:  printcmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 4635
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;nickcharlton.org.uk.		IN	A

;; ANSWER SECTION:
nickcharlton.org.uk.	603718	IN	A	78.86.198.208

;; Query time: 19 msec
;; SERVER: 208.67.222.222#53(208.67.222.222)
;; WHEN: Sat Feb 21 03:49:25 2009
;; MSG SIZE  rcvd: 53
	
</pre>

<p>What can be taken from here is the A record for the domain. That is the record which takes a domain and points it to the IP of the remote machine.</p>

<h2>dig (with @IP/Domain)</h2>

<p>Whilst not strictly a tool within it's own right, it is different from it's basic no arguments call. This allows you to pull records from a specific server, which is useful for testing the records from a new server before it is live. An example is provided below, and would be used if pulling records from a local server:</p>

<pre lang="Bash">$ dig @localhost nickcharlton.org.uk</pre>

<p>And it's response:</p>

<pre lang="Bash">
; <<>> DiG 9.4.2-P2 <<>> @kubrick.nickcharlton.org.uk nickcharlton.org.uk
; (1 server found)
;; global options:  printcmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 63435
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 2

;; QUESTION SECTION:
;nickcharlton.org.uk.		IN	A

;; ANSWER SECTION:
nickcharlton.org.uk.	604800	IN	A	78.86.198.208

;; AUTHORITY SECTION:
nickcharlton.org.uk.	604800	IN	NS	ns1.nickcharlton.org.uk.
nickcharlton.org.uk.	604800	IN	NS	ns2.nickcharlton.org.uk.
;; ADDITIONAL SECTION:
ns1.nickcharlton.org.uk. 10800	IN	A	92.243.13.80
ns2.nickcharlton.org.uk. 10800	IN	A	78.86.198.208
;; Query time: 27 msec
;; SERVER: 92.243.13.80#53(92.243.13.80)
;; WHEN: Sat Feb 21 03:50:44 2009
;; MSG SIZE  rcvd: 121
</pre>

<p>Note the increase in the details of the records. I'm not entirely sure why this happens, so if you could enlighten me, please do. (Also note that the appropriate call I used was towards my server directly, and not local host, as I don't have a DNS server here.)</p>

<h2>rndc</h2> 

<p>This tool allows you to deal with your current DNS settings. The most commonly use argument of this is "reload" and that allows you to flush, or reload your DNS settings so that they are all fresh.</p>

<pre lang="Bash">$ rndc reload</pre> 

<h2>host</h2>

<p>Host translates IP's from domains and vice versa. This is what happens when you query a domain, you get an IP response. It can also be used backwards.</p>

<pre lang="Bash">$ host nickcharlton.org.uk</pre>

<pre lang="Bash">
nickcharlton.org.uk has address 78.86.198.208
nickcharlton.org.uk mail is handled by 20 fb.mail.gandi.net.
nickcharlton.org.uk mail is handled by 10 spool.mail.gandi.net.
</pre>

<h2>whois</h2>

<p>Last there is whois. This is obviously the most well known of the lot and provides ownership information for the domain. I will not provide an example here, as it will be very long, but this is simply used as below:</p>

<pre lang="Bash">$ whois nickcharlton.org.uk</pre>

