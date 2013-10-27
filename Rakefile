require 'yaml'
require 'logger'
require 'active_record'
require 'pg'

task :default => :migrate

desc "Migrate the database. Target specific version with VERSION=x"
task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
end

task :environment do
    ActiveRecord::Base.establish_connection(YAML::load_file('database.yml'))
    logger = Logger.new(File.open('database.log', 'a'))
    logger.level = Logger::ERROR
    ActiveRecord::Base.logger = logger
end
