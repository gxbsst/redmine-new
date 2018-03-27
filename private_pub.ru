# Run with: rackup private_pub.ru -s thin -E production
require "bundler/setup"
require "yaml"
require "faye"
require "private_pub"
require 'active_record'
#require 'sqlite3'
require 'mysql2'

#need require the ChatUser model
require './plugins/redmine_chat/app/models/chat_user.rb' if File.exists?( './plugins/redmine_chat/app/models/chat_user.rb')

Faye::WebSocket.load_adapter('thin')

environment = ENV['RACK_ENV'] || "development"
dbconfig = YAML.load(File.read('./config/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig[environment])

PrivatePub.load_config(File.expand_path("../config/private_pub.yml", __FILE__), environment)
run PrivatePub.faye_app
