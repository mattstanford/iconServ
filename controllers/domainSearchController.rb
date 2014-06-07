
require "net/http"
require "nokogiri"
require "open-uri"
require "json"
require "RMagick"

class MyApp < Sinatra::Application
  
  def findIconForDomain(domain)
    
    content_type :json
    
    iconsArray = getArrayOfAvailableIconsForDomain(domain)
    {'icons' => iconsArray }.to_json
    
  end
  
  #Get an array of available icons availale for this domain
  
  def getArrayOfAvailableIconsForDomain(domain)
    
    #icons = ImageInfo.where('domain = ?', domain)
    icons = ImageInfo.select('*').where('domain = ?', domain)

    if icons.size == 0
    
      icons = Array.new
      tempIconsArray = Array.new
      
      tempIconsArray.push(findFileAtPath(domain, "favicon.ico"))
      tempIconsArray.push(findIconLinkOnPage(domain, "link[rel='shortcut icon']", "href"))
      tempIconsArray.push(findIconLinkOnPage(domain, "link[rel='icon']", "href"))
      tempIconsArray.push(findIconLinkOnPage(domain, "link[rel='apple-touch-icon']", "href"))
      tempIconsArray.push(findFileAtPath(domain, "apple-touch-icon.png"))
      tempIconsArray.push(findIconLinkOnPage(domain, "meta[name='msapplication-TileImage']", "content")) 
      tempIconsArray.push(findIconLinkOnPage(domain, "meta[property='og:image']", "content"))
      
      tempIconsArray.each do |icon|
        icons.push(icon) if icon
      end

    end
    
    return icons

  end
  
  def addIconToDB
    
    
    
  end
  
  def getImageInfoFromFile(domain, fileUrl)
    
    info = getImageInfoBlob(fileUrl)
    
    if info
      
      imageInfo = ImageInfo.new
      imageInfo.url = fileUrl
      imageInfo.width = info.columns
      imageInfo.height = info.rows
      imageInfo.fileFormat = info.format
      imageInfo.domain = domain
      
      imageInfo.save
    end
        
    return imageInfo
    
  end
  
  #Tries to get a favicon from a specified file location
 
  def findFileAtPath(domain, path) 

    urlPath = "http://#{domain}/#{path}"
    
    url = getRealUrlLocation(urlPath)
    imageInfo = getImageInfoFromFile(domain, url)
    
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
        imageInfo = getImageInfoFromFile(domain, linkString)
        
      end
      
    rescue
      
      imageInfo = nil
      
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
      
    rescue
        return ""
    end
         
  end
  
  require_relative '../helpers/imageInfoHelpers'
  
end