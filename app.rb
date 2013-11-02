require 'cgi'
require 'erb'
require 'digest'
require 'digest/sha1'
require 'warden'
require 'active_record'
require 'pg'
require 'db/sinatra/activerecord'
require 'hash'
require 'erb_namespace'
require 'ldap'
require 'db/models'

class InsultsApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  salt = '0aee46c2584e3b51b227d1175941a0f6829f70ad'

  use Rack::Session::Cookie, :secret => 'nothingissecretontheinternet'

  use Warden::Manager do |config|
    config.serialize_into_session{|user| user.id }
    config.serialize_from_session{|id| User.find(id) }
    config.scope_defaults :default, :strategies => [:password]
    config.failure_app = self
  end
  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end
  Warden::Strategies.add(:password) do
    def valid?
      params['username'] && params['password']
    end

    def authenticate!
      salt = '0aee46c2584e3b51b227d1175941a0f6829f70ad'
      query = params['username']
      password = Digest::SHA1.hexdigest("#{salt}#{params['password']}")
      user = User.authenticate(query, password)
      user.nil? ? fail!('Could not login') : success!(user)
    end
  end

  configure do
    #Setup active record with Sinatra
    set :database_file, 'database.yml'
  end

  not_found do
    @request = request
    @status_code = 404
    @status = '404: Not Found'
    @message = "The page at #{request.url.split('?')[0]} was not found."
    erb :error
  end
  error 403 do
    @request = request
    @status_code = 403
    @status = '403: Forbidden'
    @message = "You don't have permission to access #{request.url.split('?')[0]} on this server."
    erb :error
  end

  get '/' do
    @request = request
    erb :home
  end
  get '/help' do
    @request = request
    erb :help
  end
  get '/about' do
    @request = request
    @status_code = ''
    @status = 'Coming Soon'
    @message = 'This page is coming soon.'
    erb :error
  end
  get '/report' do
    redirect href('/login', {'continue' => '/report'}) unless warden_handler.authenticated?
    
    @request = request
    @status_code = ''
    @status = 'Coming Soon'
    @message = 'This feature is coming soon.'
    erb :error
  end

  post '/insult' do
    #TODO: Write insult submit stuffs
    redirect href('/')
  end
  
  get '/profile' do
      redirect href('/login', {'continue' => '/profile'}) unless warden_handler.authenticated?
      
      @request = request
      @status_code = ''
      @status = 'Coming Soon'
      @message = 'Your profile page is coming soon.'
      erb :error
    end

  post '/signup' do
    username = params[:username]
    password = params[:password]
    
    #Try to authenticate with our User database
    warden_handler.authenticate
    if warden_handler.authenticated?
      redirect href('/')
    else
      #Try to authenticate with CAT LDAP
      email = Insults::LDAP.authenticate(username, password)
      if not email
        #Fail
        @request = request
        @success = false
        erb :home
      else
        #User exists in CAT LDAP
        #Add the user to our User database
        user = User.create do |u|
          u.username = username
          u.email = email
          u.password = Digest::SHA1.hexdigest("#{salt}#{password}")
        end
  
        env['warden'].set_user(user)
        
        if warden_handler.authenticated?
          redirect href('/')
        else
          redirect href('/login')
        end
      end
    end
  end

  get '/login' do
    @request = request
    erb :login
  end
  post '/login' do
    @request = request
    warden_handler.authenticate
    if warden_handler.authenticated?
      if params.has_key?('continue')
        redirect href(params[:continue])
      else
        redirect href('/')
      end
    else
      @success = false
      erb :login
    end
  end
  get '/logout' do
    if warden_handler.authenticated?
      warden_handler.logout
      if params.has_key?('continue')
        redirect href(params[:continue])
      else
        redirect href('/')
      end
    else
      redirect href('/')
    end
  end
  post '/unauthenticated' do
    redirect href('/login')
  end

  helpers do
    def get_scripts
      template = File.read('templates/scripts.erb')
      path = request.path_info
      case path
      when '/'
        (show_sign_in) ? template.erb({:scripts => ['js/signup.js']}) : template.erb({:scripts => ['js/submit.js']})
      when '/signup'
        template.erb({:scripts => ['js/signup.js']})
      when '/login'
        template.erb({:scripts => ['js/login.js']})
      else
        ''
      end
    end

    def href(reference, hash={})
      return '#' if request.path_info == reference && hash.empty?
      url = "/~chances/insults#{reference}"
      url_args = ''
      if hash.empty?
        "#{url}"
      else
        hash.each { |key, value| hash[key] = CGI::escape(value) }
        url_args = hash.flatten('=', '&')
        "#{url}?#{url_args}"
      end
    end

    def class_attr(reference, classes, default_classes=[])
      return '' if reference != request.path_info && default_classes.empty?
      return " class=\"#{default_classes.join(' ')}\"" if reference != request.path_info
      " class=\"#{(classes + default_classes).join(' ')}\""
    end

    def warden_handler
      env['warden']
    end

    def current_user
      warden_handler.user
    end

    def check_authentication
      redirect href('/login') unless warden_handler.authenticated?
    end

    def show_sign_in
      not warden_handler.authenticated?
    end
  end
end
