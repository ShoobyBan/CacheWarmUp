#!/usr/bin/env ruby

#self contained thread pool madness from burgestrand.se
# License (X11 License)
# =====================
#
# Copyright (c) 2012, Kim Burgestrand <kim@burgestrand.se>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
require 'thread'
class Pool
  def initialize(size)
    @size = size
    @jobs = Queue.new
    @pool = Array.new(@size) do |i|
      Thread.new do
        Thread.current[:id] = i
        catch(:exit) do
          loop do
            job, args = @jobs.pop
            job.call(*args)
          end
        end
      end
    end
  end
  def schedule(*args, &block)
    @jobs << [block, args]
  end
  def shutdown
    @size.times do
      schedule { throw :exit }
    end
    @pool.map(&:join)
  end
end

# the script itself

require 'net/http'

if ARGV.empty?
	puts "Warms up site cache by downloading,parsing and using sitemap.xml"
	puts "Version: 0.1"
	puts "Usage: #{$0} www.someurl.tld"
	exit
end

purl = ARGV.first
uri = "http://#{purl}/sitemap.xml"
smxml = Net::HTTP.get_response(URI.parse(uri)).body

p = Pool.new(10)

smxml.scan(/<loc>(.*)<\/loc>/).map do |loc|
	loc = loc.first.gsub('&amp;','&')
	p.schedule do
		puts "Getting #{loc} #{Thread.current[:id]}"
		length = Net::HTTP.get_response(URI.parse(loc)).body.length
		puts " => Got #{loc} #{length}"
	end
end

at_exit { p.shutdown }
