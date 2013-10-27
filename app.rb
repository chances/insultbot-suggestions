require 'rubygems'

ENV['GEM_PATH'] = '/u/chances/.gem/ruby/1.8/'
require 'sinatra'
require 'pg'

class InsultsApp < Sinatra::Base
#Super simple sinatra app
    get '/' do
        'This is a simple app!'
    end
end
