
class MyApp < Sinatra::Application
  
  #Checks to see if the url supplied is the "real" url.  Supplies a redirected url if it is not
  
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
        return ""
      end
      
    rescue
        return ""
    end
         
  end
  
end