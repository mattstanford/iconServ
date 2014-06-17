require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'sinatra/async'

class MyApp < Sinatra::Application
  register Sinatra::Async

  configure :development do
    register Sinatra::Reloader
    enable :logging
  end
  
  set :database, "sqlite3:db/iconServ.db"
  
end

require_relative 'routes/init'
require_relative 'models/imageInfo'