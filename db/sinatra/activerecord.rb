require 'sinatra/base'
require 'active_record'
require 'logger'

module Sinatra
  module ActiveRecordHelper
    def database
      settings.database
    end
  end

  module ActiveRecordExtension
    def database=(spec)
      set :database_spec, spec
      @database = nil
      database
    end

    def database
      @database ||= begin
        ActiveRecord::Base.logger = activerecord_logger
        ActiveRecord::Base.establish_connection(resolve_spec(database_spec))
        ActiveRecord::Base.connection
        ActiveRecord::Base
      end
    end

    def database_file=(path)
      require 'pathname'

      return if root.nil?
      path = File.join(root, path) if Pathname.new(path).relative?

      if File.exists?(path)
        require 'yaml'
        require 'erb'

        database_hash = YAML.load(ERB.new(File.read(path)).result) || {}
        database_hash = database_hash[environment.to_s] if database_hash[environment.to_s]
        set :database, database_hash
      end
    end

    protected

    def self.registered(app)
      app.set :activerecord_logger, Logger.new(File.open('database.log', 'a'))
      app.set :database_spec, ENV['DATABASE_URL']
      app.set :database_file, "config/database.yml"
      app.database if app.database_spec
      app.helpers ActiveRecordHelper

      # re-connect if database connection dropped
      app.before { ActiveRecord::Base.verify_active_connections! if ActiveRecord::Base.respond_to?(:verify_active_connections!) }
      app.after  { ActiveRecord::Base.clear_active_connections! }
    end

    private

    def resolve_spec(database_spec)
      if database_spec.is_a?(String)
        database_spec.sub(/^sqlite:/, "sqlite3:")
      else
        database_spec
      end
    end
  end

  register ActiveRecordExtension
end
