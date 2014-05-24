
class MyApp < Sinatra::Application
  
  get '/*' do
    path = params[:splat].first
    "path: #{path}" 
  end
  
end