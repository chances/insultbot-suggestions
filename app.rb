require 'sinatra'
require 'active_record'
require 'pg'

class InsultsApp < Sinatra::Base
#Super simple sinatra app
    get '/' do
        'This is a simple app!'
    end
end
