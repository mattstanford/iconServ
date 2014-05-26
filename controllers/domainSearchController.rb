
require "net/http"

class MyApp < Sinatra::Application
  
  def findIconForDomain(domain)
    
    #"controller hi: #{domain}"
    favIconUrl = "#{domain}/favicon.ico"
    
    #url = URI.parse(favIconUrl)
    #req = Net::HTTP.new(url.host, url.port)
    #res = req.request_head(url.path)
    
    #"code for #{domain}: #{res.code}"
    
    "favIconUrl: #{favIconUrl}"
    
  end
  
end