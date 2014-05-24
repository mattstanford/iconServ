require 'sinatra'

class MyApp < Sinatra::Application

  enable :logging
  
end

require_relative 'routes/init'