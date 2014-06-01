require 'sinatra/base'
require 'sinatra/reloader'
require "sinatra/activerecord"

class MyApp < Sinatra::Application

  configure :development do
    register Sinatra::Reloader
    enable :logging
  end
  
  set :database, "sqlite3:db/iconServ.db"
  
end

require_relative 'routes/init'