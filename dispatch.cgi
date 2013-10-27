#!/usr/bin/ruby

require 'rubygems'
require 'rack'
ENV['GEM_PATH'] = '/u/chances/.gem/ruby/1.8/'
require File.join(File::dirname(__FILE__), "app.rb")

Rack::Handler::CGI.run(InsultsApp)
