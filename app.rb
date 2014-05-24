require 'sinatra/base'
require 'sinatra/reloader'

class MyApp < Sinatra::Application

  configure :development do
    register Sinatra::Reloader
    enable :logging
  end
  
end

require_relative 'routes/init'