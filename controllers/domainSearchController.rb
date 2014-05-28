
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
  
    urlString = "http://#{domain}/"
    
    parsedPage = Nokogiri::HTML(open(urlString))
    faviconLinkElement = parsedPage.css("link[rel='shortcut icon']")
    faviconLink = faviconLinkElement[0]['href']
    
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
    
    rescue URI::InvalidURIError => err
      
      return ""
      
    rescue SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      
      return ""
      
    end
         
  end
  
end