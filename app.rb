require 'active_record'
require 'pg'
require 'db/sinatra/activerecord'

require 'db/insult'

class InsultsApp < Sinatra::Base
    register Sinatra::ActiveRecordExtension

    #Setup active record with Sinatra
    set :database_file, 'database.yml'

    get '/' do
        @insult_count = Insult.approved.count
        erb "<h1>Submit an Insult <small>#{request.path_info}</small></h1>"
    end

    get '/login' do
        erb :login
    end

    helpers do
        def show_sign_in
            request.path_info != '/admin'
        end

        def href(reference)
            "/~chances/insults#{reference}"
        end
    end
end
