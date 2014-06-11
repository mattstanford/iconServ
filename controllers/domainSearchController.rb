
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
  
  def findIconForDomain(searchString)
    
    iconsArray = getArrayOfAvailableIconsForDomain(searchString)
    
    if iconsArray
      {'icons' => iconsArray }.to_json
    else
      [].to_json
    end
    
  end
  
  #Get an array of available icons availale for this domain
  
  def getArrayOfAvailableIconsForDomain(searchString)
    
    url = NetworkHelper.getValidUrl(searchString)
    
    if url
      
      domain = NetworkHelper.getRealDomainName(url)
      
      if domain
      
        icons = ImageInfo.where('domain = ?', domain)
    
        if icons.size == 0
        
          icons = Array.new
   
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
    
        end #if icons.size == 0
        
      end  #if domain
      
    end  #if url
    
    return icons

  end
  
  def getImageInfoFromFile(fileUrl)
    
    blob = ImageInfoHelper.getImageBlob(fileUrl)
    
    if blob
      
      imageInfo = ImageInfo.new
      imageInfo.url = fileUrl
      imageInfo.width = blob.columns
      imageInfo.height = blob.rows
      imageInfo.fileFormat = blob.format
      imageInfo.domain = NetworkHelper.getRealDomainName(fileUrl)
      
      imageInfo.save
    end
        
    return imageInfo
    
  end
  
  #Tries to get a favicon from a specified file location
 
  def findFileAtPath(urlString, path) 
    
    urlString = "#{urlString}/#{path}"
    
    #Account for redirects
    url = NetworkHelper.getRealUrlLocation(urlString)
    
    imageInfo = getImageInfoFromFile(url)
    
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
        imageInfo = getImageInfoFromFile(linkString)
        
      end
      
    rescue
      
      imageInfo = nil
      
    end
      
    return imageInfo
    
  end
  
end