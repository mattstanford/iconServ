
require "net/http"
require "nokogiri"
require "open-uri"

class MyApp < Sinatra::Application
  
  def findIconForDomain(domain)
    
    #findFavIconString = findFavIcon(domain)
    findFavIconInLinkTag(domain)
    #"favIconUrl: #{favIconUrl}"
    
  end
  
  #Tries to get the favicon from the root folder of the domain
 
  def findFavIcon(domain) 

    favIconUrl = "http://#{domain}/favicon.ico"
    
    url = getRealUrlLocation(favIconUrl)
    
    
  end
 
  #Tries to get the favicon from a "link" tag in the head of the HTML page
   
  def findFavIconInLinkTag(domain)
  
  
    begin

      urlString = "http://#{domain}/"
      
      parsedPage = Nokogiri::HTML(open(urlString))
      faviconLinkElement = parsedPage.css("link[rel='shortcut icon']")
      
      if faviconLinkElement.size > 0
      
        faviconLink = faviconLinkElement[0]['href']
        
      end
      
    rescue URI::InvalidURIError, SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => err
      
      faviconLInk = ""
      
    end
      
    return faviconLink
    
  end
  
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
      
    rescue URI::InvalidURIError, SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => err
        
        return ""
    end
         
  end
  
end