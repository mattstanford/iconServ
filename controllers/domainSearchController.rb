
require "net/http"
require "nokogiri"
require "open-uri"

class MyApp < Sinatra::Application
  
  def findIconForDomain(domain)
    
    iconsArray = getHashOfAvailableIconsForDomain(domain)
    
    "favicons: " + iconsArray.join(",") 
    
  end
  
  #Get an array of available icons availale for this domain
  
  def getHashOfAvailableIconsForDomain(domain)
    
    icons = Array.new
    
    rootIcon = findFileAtPath(domain, "favicon.ico")
    icons.push(rootIcon) if rootIcon.size > 0
    
    linkShortcutIcon = findIconLinkOnPage(domain, "link[rel='shortcut icon']", "href")
    icons.push(linkShortcutIcon) if linkShortcutIcon.size > 0
    
    linkIcon = findIconLinkOnPage(domain, "link[rel='icon']", "href")
    icons.push(linkIcon) if linkIcon.size > 0
    
    appleTouchLinkIcon = findIconLinkOnPage(domain, "link[rel='apple-touch-icon']", "href")
    icons.push(appleTouchLinkIcon) if (appleTouchLinkIcon.size > 0)
     
    appleTouchIcon = findFileAtPath(domain, "apple-touch-icon.png")
    icons.push(appleTouchIcon) if appleTouchIcon.size > 0
    
    microsoftTileLink = findIconLinkOnPage(domain, "meta[name='msapplication-TileImage']", "content")
    icons.push(microsoftTileLink) if microsoftTileLink.size > 0
    
    openGraphLink = findIconLinkOnPage(domain, "meta[property='og:image']", "content")
    icons.push(openGraphLink) if openGraphLink.size > 0
    
    return icons

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