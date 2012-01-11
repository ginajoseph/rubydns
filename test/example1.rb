#!/usr/bin/env ruby

# Copyright (c) 2009, 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
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
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'rubygems'
require 'rubydns'

# You can specify other DNS servers easily
# $R = Resolv::DNS.new(:nameserver => ["xx.xx.1.1", "xx.xx.2.2"])

$R = Resolv::DNS.new
Name = Resolv::DNS::Name

RubyDNS::run_server do
	# For this exact address record, return an IP address
	match("dev.mydomain.org", :A) do |transaction|
		transaction.respond!("10.0.0.80")
	end

	match("80.0.0.10.in-addr.arpa", :PTR) do |transaction|
		transaction.respond!(Name.create("dev.mydomain.org."))
	end

	match("dev.mydomain.org", :MX) do |transaction|
		transaction.respond!(10, Name.create("mail.mydomain.org."))
	end
	
	match(/^test([0-9]+).mydomain.org$/, :A) do |match_data, transaction|
		offset = match_data[1].to_i
		
		if offset > 0 && offset < 10
			logger.info "Responding with address #{"10.0.0." + (90 + offset).to_s}..."
			transaction.respond!("10.0.0." + (90 + offset).to_s)
		else
			logger.info "Address out of range: #{offset}!"
			false
		end
	end

	# Default DNS handler
	otherwise do |transaction|
		logger.info "Passing DNS request upstream..."
		transaction.passthrough!($R)
	end
end
