require 'active_record'
require 'pg'
require 'sinatra'
require 'db/sinatra/activerecord'

require 'db/insult'

class InsultsApp < Sinatra::Base
    register Sinatra::ActiveRecordExtension

    #Setup active record with Sinatra
    set :database_file, 'database.yml'

    get '/' do
        "There are #{Insult.count} insults."
    end
end
