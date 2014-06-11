
require "net/http"
require "nokogiri"
require "open-uri"
require "json"
require "RMagick"
require_relative '../models/imageInfo'
require_relative '../helpers/networkHelper'
require_relative '../helpers/imageInfoHelper'

require 'sinatra/base'
require 'sinatra/reloader'
require "sinatra/activerecord"


#class MyApp < Sinatra::Application
class DomainSearchController
  
  def findIconForDomain(domain)
    
    iconsArray = getArrayOfAvailableIconsForDomain(domain)
    {'icons' => iconsArray }.to_json
    
  end
  
  #Get an array of available icons availale for this domain
  
  def getArrayOfAvailableIconsForDomain(domain)
    
    icons = ImageInfo.where('domain = ?', domain)

    if icons.size == 0
    
      icons = Array.new
      url = NetworkHelper.getValidUrl(domain)
      
      if url
    
        tempIconsArray = Array.new
        
        tempIconsArray.push(findFileAtPath(url, "favicon.ico"))
        tempIconsArray.push(findIconLinkOnPage(url, "link[rel='shortcut icon']", "href"))
        tempIconsArray.push(findIconLinkOnPage(url, "link[rel='icon']", "href"))
        tempIconsArray.push(findIconLinkOnPage(url, "link[rel='apple-touch-icon']", "href"))
        tempIconsArray.push(findFileAtPath(url, "apple-touch-icon.png"))
        tempIconsArray.push(findIconLinkOnPage(url, "meta[name='msapplication-TileImage']", "content")) 
        tempIconsArray.push(findIconLinkOnPage(url, "meta[property='og:image']", "content"))
        
        tempIconsArray.each do |icon|
          icons.push(icon) if icon
        end
        
      end

    end
    
    return icons

  end
  
  def addIconToDB
    
    
    
  end
  
  def getImageInfoFromFile(domain, fileUrl)
    
    info = ImageInfoHelper.getImageInfoBlob(fileUrl)
    
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
 
  def findFileAtPath(urlString, path) 
    
    urlString = "#{urlString}/#{path}"
    
    url = NetworkHelper.getRealUrlLocation(urlString)
    imageInfo = getImageInfoFromFile(urlString, url)
    
    return imageInfo
    
  end
 
  #Tries to get the favicon from a tag in the head of the HTML page
   
  def findIconLinkOnPage(urlString, cssTagLink, cssTagAttribute)

    begin

      imageInfo = nil
      
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
  
end