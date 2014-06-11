
require "open-uri"

class NetworkHelper
  
  def self.getValidUrl(domain)
    
    urlString = urlString = "http://#{domain}/"
    
    #Check to make sure the url is valid
    if !urlString.match /\A#{URI::regexp(['http', 'https'])}\z/
    
      urlString = nil
        
    end
    
    return urlString
    
  end
  
  #Checks to see if the url supplied is the "real" url.  Supplies a redirected url if it is not
  
  def self.getRealUrlLocation(urlString)
    
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
        return ""
      end
      
    rescue
        return ""
    end
         
  end
  
end