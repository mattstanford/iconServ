
class MyApp < Sinatra::Application
  
  get '/*' do
    
   path = params[:splat].first
   findIconForDomain(path)
   
  end
  
  require_relative '../controllers/domainSearchController'
  
end