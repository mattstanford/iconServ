
require "net/http"

class MyApp < Sinatra::Application
  
  def findIconForDomain(domain)
    
    findFavIconString = findFavIcon(domain)
    
    #"favIconUrl: #{favIconUrl}"
    
  end
  
  def findFavIcon(domain) 

    favIconUrl = "http://#{domain}/favicon.ico"
    
    url = getRealUrlLocation(favIconUrl)
    
    
  end
  
  def getRealUrlLocation(urlString)
    
    begin
    
      url = URI.parse(urlString)
      req = Net::HTTP.new(url.host, url.port)
      res = req.request_head(url.path)
        
      if res.code == "200"
        return urlString
      #Redirect (300 codes)
      elsif res.code.to_i / 100 == 3
        return res.header['location']
      else
        return false
      end
    
    rescue URI::InvalidURIError => err
      
      return ""
      
    rescue SocketError => se
      
      return ""
      
    end
         
  end
  
end