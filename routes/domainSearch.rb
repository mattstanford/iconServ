
#require_relative '../controllers/testController'
require_relative '../controllers/domainSearchController'

class MyApp < Sinatra::Application
  
  get '/*' do
    
   path = params[:splat].first
   #findIconForDomain(path)
   
   content_type :json
   
   domainSearchController = DomainSearchController.new
   domainSearchController.findIconForDomain(path)
   
  end
  

  
end