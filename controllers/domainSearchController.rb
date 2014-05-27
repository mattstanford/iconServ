
require "net/http"

class MyApp < Sinatra::Application
  
  def findIconForDomain(domain)
    
    findFavIconString = findFavIcon(domain)
    
    #"favIconUrl: #{favIconUrl}"
    
  end
  
  def findFavIcon(domain)
    
    begin
      favIconUrl = "http://#{domain}/favicon.ico"   
      doesExist = urlExists?(favIconUrl)
      
      if(doesExist)
        return "icon exists!"
      else
        return "icon doesn't exist!"
      end
      
    rescue URI::InvalidURIError => err
      
      return "invalid url!"
      
    end
    
  end
  
  def urlExists?(urlString)
    
    url = URI.parse(urlString)
    req = Net::HTTP.new(url.host, url.port)
    res = req.request_head(url.path)
      
    if res.code == 200
      return true
    else
      return false
    end
         
  end
  
end