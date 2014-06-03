
require "net/http"
require "nokogiri"
require "open-uri"
require "json"
require "RMagick"

class MyApp < Sinatra::Application
  
  def findIconForDomain(domain)
    
    content_type :json
    
    iconsArray = getHashOfAvailableIconsForDomain(domain)
    {'icons' => iconsArray }.to_json
    
  end
  
  #Get an array of available icons availale for this domain
  
  def getHashOfAvailableIconsForDomain(domain)
    
    icons = Array.new
    
    rootIconInfo = findFileAtPath(domain, "favicon.ico")
    icons.push(rootIconInfo) if rootIconInfo != nil
    
    #linkShortcutIconInfo = findIconLinkOnPage(domain, "link[rel='shortcut icon']", "href")
    #icons.push(linkShortcutIconInfo) if linkShortcutIconInfo != nil
    
    #linkIconInfo = findIconLinkOnPage(domain, "link[rel='icon']", "href")
    #icons.push(linkIconInfo) if linkIconInfo != nil
    
    #appleTouchLinkIconInfo = findIconLinkOnPage(domain, "link[rel='apple-touch-icon']", "href")
    #icons.push(appleTouchLinkIconInfo) if appleTouchLinkIconInfo != nil
     
    #appleTouchIconInfo = findFileAtPath(domain, "apple-touch-icon.png")
    #icons.push(appleTouchIconInfo) if appleTouchIconInfoInfo != nil
    
    #microsoftTileLinkInfo = findIconLinkOnPage(domain, "meta[name='msapplication-TileImage']", "content")
    #icons.push(microsoftTileLinkInfo) if microsoftTileLinkInfo != nil
    
    #openGraphLinkInfo = findIconLinkOnPage(domain, "meta[property='og:image']", "content")
    #icons.push(openGraphLinkInfo) if openGraphLinkInfo != nil
    
    return icons

  end
  
  def addIconToDB
    
    
    
  end
  
  def getImageInfoFromFile(fileUrl)
    
    imageInfo = ImageInfo.new
    
    # Get the file type by getting the string after the last "."
    fileFormat = fileUrl.split('.').last
    
    #Read in the image using the RMagick library
    image = Magick::ImageList.new
    imageBlob = open(fileUrl)
    image.from_blob(imageBlob.read){self.format=fileFormat}
    
    imageInfo.url = fileUrl
    imageInfo.width = image.columns
    imageInfo.height = image.rows
    imageInfo.type = fileFormat
    
    return imageInfo
    
  end
  
  #Tries to get a favicon from a specified file location
 
  def findFileAtPath(domain, path) 

    urlPath = "http://#{domain}/#{path}"
    
    url = getRealUrlLocation(urlPath)
    imageInfo = getImageInfoFromFile(url)
    
    return imageInfo
    
  end
 
  #Tries to get the favicon from a tag in the head of the HTML page
   
  def findIconLinkOnPage(domain, cssTagLink, cssTagAttribute)
  
  
    begin

      imageInfo = nil
      urlString = "http://#{domain}/"
      
      parsedPage = Nokogiri::HTML(open(urlString))
      elements = parsedPage.css(cssTagLink)
      
      if elements.size > 0
      
        linkString = elements[0][cssTagAttribute]     
        imageInfo = getImageInfoFromFile(linkString)
        
      end
      
    rescue URI::InvalidURIError, SocketError, Errno::ECONNREFUSED, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
       Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => err
      
      linkString = nil
      
    end
      
    return imageInfo
    
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