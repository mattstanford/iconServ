
require "net/http"
require "nokogiri"
require "open-uri"

class MyApp < Sinatra::Application
  
  def findIconForDomain(domain)
    
    rootIcon = findFileAtPath(domain, "favicon.ico")
    linkIcon = findIconLinkOnPage(domain, "link[rel='shortcut icon']", 'href')
    #"favIconUrl: #{favIconUrl}"
    
    returnString = "#{rootIcon}"
    
    "favicon: "  + rootIcon + "," + linkIcon
    
  end
  
  #Tries to get a favicon from a specified file location
 
  def findFileAtPath(domain, path) 

    urlPath = "http://#{domain}/#{path}"
    
    url = getRealUrlLocation(urlPath)
    
    
  end
 
  #Tries to get the favicon from a tag in the head of the HTML page
   
  def findIconLinkOnPage(domain, cssTagLink, cssTagAttribute)
  
  
    begin

      linkString = ""
      urlString = "http://#{domain}/"
      
      parsedPage = Nokogiri::HTML(open(urlString))
      elements = parsedPage.css(cssTagLink)
      
      if elements.size > 0
      
        linkString = elements[0][cssTagAttribute]
        
      end
      
    rescue URI::InvalidURIError, SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => err
      
      linkString = ""
      
    end
      
    return linkString
    
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