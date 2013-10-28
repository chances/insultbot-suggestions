require 'erb'
require 'active_record'
require 'pg'
require 'db/sinatra/activerecord'

require 'erb_namespace'

require 'db/insult'

class InsultsApp < Sinatra::Base
    register Sinatra::ActiveRecordExtension

    #Setup active record with Sinatra
    set :database_file, 'database.yml'

    get '/' do
        @request = request
        @insult_count = Insult.approved.count
        erb :submit
    end

    get '/login' do
        erb :login
    end

    post '/login' do
        @success = false
        erb :login
    end

    helpers do
        def get_scripts
            template = File.read('templates/scripts.erb')
            path = request.path_info
            case path
                when '/login'
                    template.erb({:scripts => ['js/login.js']})
                else
                    ''
            end
        end

        def href(reference)
            "/~chances/insults#{reference}"
        end

        def show_sign_in
            request.path_info != '/admin'
        end
    end
end
