require "./app"
Rack::Handler::WEBrick.run(MyApp.new, :Port => 9292)