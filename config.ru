require "./app"
Rack::Handler::Thin.run(MyApp.new, :Port => 9292)
