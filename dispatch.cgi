#!/usr/bin/ruby

require 'rubygems'
require 'rack'

cgi_log = File.open("cgi.log", "a")
#STDOUT.reopen cgi_log
STDERR.reopen cgi_log
STDOUT.sync = true

ENV['GEM_PATH'] = '/u/chances/.gem/ruby/1.8/'
require 'sinatra'

module Rack
  class Request
    def path_info
      @env["REDIRECT_URL"].to_s.sub('/~chances/insults', '')
    end
    def path_info=(s)
      @env["REDIRECT_URL"] = s.to_s
    end
    def url
      url = scheme + "://"
      url << host

      if scheme == "https" && port != 443 ||
        scheme == "http" && port != 80
        url << ":#{port}"
      end

      url << fullpath
      url.sub('/dispatch.cgi', '')
    end
  end
end

require File.join(File::dirname(__FILE__), "app.rb")

Rack::Handler::CGI.run(InsultsApp)
