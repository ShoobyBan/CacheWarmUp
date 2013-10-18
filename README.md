CacheWarmUp
===========

Warming up cache based on sitemap.xml

You can use the tool on the server (sometimes preferable, just 
think about speed and network traffic) or from other computers.

Basic usage:
$ ./warmup.rb www.someurl.tld

# Basics

It will
* download http://www.someurl.tld/sitemap.xml 
* parse that sitemap for urls
* run through that list of urls, downloading every HTML to warmup the cache

I use the quick and simple Ruby thread pool from Kim Burgestrand (X11 License), 
http://burgestrand.se/articles/quick-and-simple-ruby-thread-pool.html
I include it in the code so it's self contained.

# Requirements

Requirements are:
- Ruby
- threads
- net/http

So basically everything you need is a basic Ruby installation.
