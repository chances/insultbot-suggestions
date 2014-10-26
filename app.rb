require 'cgi'
require 'erb'
require 'digest'
require 'digest/sha1'
require 'warden'
require 'active_record'
require 'pg'
require 'json'
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
    #Set log level
    set :logging, Logger::DEBUG
    #set :logging, Logger::WARN
    #Setup active record with Sinatra
    set :database_file, 'database.yml'
  end

  before do
    @request = request
  end

  not_found do
    @status_code = 404
    @status = '404: Not Found'
    @message = "The page at #{request.url.split('?')[0]} was not found."
    erb :error
  end
  error 403 do
    @status_code = 403
    @status = '403: Forbidden'
    @message = "You don't have permission to access #{request.url.split('?')[0]} on this server."
    erb :error
  end

  get '/' do
    erb :home
  end
  get '/help' do
    erb :help
  end
  get '/about' do
    erb :about
  end
  get '/report' do
    redirect href('/login', {'continue' => '/report'}) unless warden_handler.authenticated?

    @status_code = ''
    @status = 'Report an Insult <small>Coming Soon</small>'
    @message = 'This feature is coming soon.'
    erb :error
  end

  post '/insult' do
    redirect href('/login', {'continue' => '/'}) unless warden_handler.authenticated?
    if params['insult']
      #Add the insult to the Insults database
      current_user.insults.create do |insult|
        insult.insult = params['insult']
      end
    end
    redirect href('/')
  end
  post '/insult/:id' do
    response = {}
    begin
      id = Integer(params[:id])
      if params['insult'] and (warden_handler.authenticated? or current_user.admin)
        begin
          insult = nil
          if current_user.admin
            insult = Insult.find(id)
          else
            insult = current_user.insults.find(id)
          end
          insult.with_lock do
            insult.insult = params['insult']
            insult.approved = false
            insult.published = false
            insult.save
          end
          response['success'] = true
        rescue ActiveRecord::RecordNotFound
          response['success'] = false
          response['error'] = 'notFound'
        end
      else
        response['success'] = false
        response['error'] = 'invalid'
      end
    rescue ArgumentError
       response['success'] = false
       response['error'] = 'invalidParams'
    end
    response.to_json
  end
  get '/insult/random' do
    insult = Insult.random
    unless insult.nil?
      user = insult.user
      user.insult_count += 1
      user.save
    end
    if params['format'] == 'json'
      content_type :json
      if insult.nil?
        {'status' => 'error', 'code' => 'NO_RESULTS'}.to_json
      else
        {'status' => 'success', 'insult' => insult.insult}.to_json
      end
    elsif params['format'] == 'text'
      content_type :text
      if insult.nil?
        ""
      else
        insult.insult
      end
    else
      if insult.nil?
        @status_code = '503'
        @status = 'Random Insult'
        @message = 'There are no insults available.'
        erb :error
      else
        if warden_handler.authenticated?
          @insult = insult(insult.insult)
        else
          @insult = h(insult.insult.gsub('<NICK>', 'you'))
        end
        erb :insult
      end
    end
  end
  get '/insult/:id/approve' do
    response = {}
    begin
      id = Integer(params[:id])
      if warden_handler.authenticated? and current_user.admin
        begin
          insult = Insult.find(id)
          insult.approved = true
          insult.published = true
          insult.save
          response['success'] = true
        rescue ActiveRecord::RecordNotFound
          response['success'] = false
          response['error'] = 'notFound'
        end
      else
        response['success'] = false
        response['error'] = 'invalid'
      end
    rescue ArgumentError
      response['success'] = false
      response['error'] = 'invalidParams'
    end
    response.to_json
  end
  get '/insult/:id/disapprove' do
    response = {}
    begin
      id = Integer(params[:id])
      if warden_handler.authenticated? and current_user.admin
        begin
          insult = Insult.find(id)
          insult.approved = false
          insult.published = true
          insult.save
          response['success'] = true
        rescue ActiveRecord::RecordNotFound
          response['success'] = false
          response['error'] = 'notFound'
        end
      else
        response['success'] = false
        response['error'] = 'invalid'
      end
    rescue ArgumentError
      response['success'] = false
      response['error'] = 'invalidParams'
    end
    response.to_json
  end
  post '/insult/:id/delete' do
    response = {}
    begin
      id = Integer(params[:id])
      if warden_handler.authenticated? or current_user.admin
        begin
          if current_user.admin
            Insult.find(id).destroy
          else
            current_user.insults.find(id).destroy
          end
          response['success'] = true
        rescue ActiveRecord::RecordNotFound
          response['success'] = false
          response['error'] = 'notFound'
        end
      else
        response['success'] = false
        response['error'] = 'invalid'
      end
    rescue ArgumentError
      response['success'] = false
      response['error'] = 'invalidParams'
    end
    response.to_json
  end
  
  get '/profile' do
    redirect href('/login', {'continue' => '/profile'}) unless warden_handler.authenticated?

    erb :profile
  end
  get '/profile/delete' do
    redirect href('/login', {'continue' => '/profile'}) unless warden_handler.authenticated?

    #TODO: Implement profile deletion
    #user = current_user
    #warden_handler.logout
    #user.destroy

    redirect href('/profile')
  end
  post '/profile/:id' do
    redirect href('/login', {'continue' => '/profile'}) unless warden_handler.authenticated?

    params_alias = params[:alias]

    current_user.alias = params_alias.empty? ? nil : params_alias
    current_user.email = params[:email]
    current_user.save

    redirect href('/profile')
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
      if email
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
      else
        #Fail
        @success = false
        erb :home
      end
    end
  end

  get '/login' do
    erb :login
  end
  post '/login' do
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
    def get_styles
      template = File.read('templates/styles.erb')
      path = request.path_info
      case path
        when '/'
          styles = [href('css/index.css')]
          if show_sign_in
            styles.push(href('css/signup.css'))
          else
            styles.push(href('css/submit.css'))
          end
          template.erb({:styles => styles})
        when '/login'
          template.erb({:styles => [href('css/login.css')]})
        when '/profile'
          template.erb({:styles => [href('css/profile.css')]})
        when '/help'
          template.erb({:styles => [href('css/help.css')]})
        else
          ''
      end
    end

    def get_scripts
      template = File.read('templates/scripts.erb')
      path = request.path_info
      case path
      when '/'
        (show_sign_in) ? template.erb({:scripts => [href('js/signup.js')]}) : template.erb({:scripts => [href('js/submit.js')]})
      when '/signup'
        template.erb({:scripts => [href('js/signup.js')]})
      when '/login'
        template.erb({:scripts => [href('js/login.js')]})
        when '/profile'
          template.erb({:scripts => [href('js/profile.js')]})
      else
        ''
      end
    end

    def href(reference, hash={})
      return '#' if request.path_info == reference && hash.empty?
      #Add preceding slash if needed
      reference = "/#{reference}" unless reference.starts_with?('/')
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
    
    def h(escape_str)
      Rack::Utils.escape_html(escape_str)
    end
    
    def insult(insult_str)
      h(insult_str.gsub('<NICK>', current_user.handle))
    end
    
    def date(date_str)
      date_str.strftime('%a, %b %d, %Y at %l:%M %p')
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
