
require "net/http"
require "nokogiri"
require "open-uri"

class MyApp < Sinatra::Application
  
  def findIconForDomain(domain)
    
    #findFavIconString = findFavIcon(domain)
    findFavIconInLinkTag(domain)
    #"favIconUrl: #{favIconUrl}"
    
  end
  
  def findFavIcon(domain) 

    favIconUrl = "http://#{domain}/favicon.ico"
    
    url = getRealUrlLocation(favIconUrl)
    
    
  end
  
  def findFavIconInLinkTag(domain)
  
  
    begin

      urlString = "http://#{domain}/"
      
      parsedPage = Nokogiri::HTML(open(urlString))
      faviconLinkElement = parsedPage.css("link[rel='shortcut icon']")
      
      if faviconLinkElement.size > 0# and faviconLinkElement[0].has_key?('href')
      
        faviconLink = faviconLinkElement[0]['href']
        
      end
      
    rescue URI::InvalidURIError, SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => err
      
      faviconLInk = ""
      
    end
      
    return faviconLink
    
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
        return ""
      end
      
    rescue URI::InvalidURIError, SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => err
        
        return ""
    end
         
  end
  
end