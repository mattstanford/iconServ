
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
require 'sinatra/activerecord'
require 'sinatra/async'


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
      
      icons = ImageInfo.where('domain = ?', url.host)
  
      if icons.size == 0
      
        icons = self.createImageInfoArray(url)
  
      end #if icons.size == 0
      
    end  #if url
    
    return icons

  end
  
  def createImageInfoArray(url)
    
    icons = Array.new
    tempIconsArray = Array.new
    
    begin
      html = open(url.to_s)
      htmldata = html.read
      
      tempIconsArray.push(findFileAtPath(url, "favicon.ico"))
      tempIconsArray.push(findIconLinkOnPage(url, "link[rel='shortcut icon']", "href", htmldata))
      tempIconsArray.push(findIconLinkOnPage(url, "link[rel='icon']", "href", htmldata))
      tempIconsArray.push(findIconLinkOnPage(url, "link[rel='apple-touch-icon']", "href", htmldata))
      tempIconsArray.push(findFileAtPath(url, "apple-touch-icon.png"))
      tempIconsArray.push(findIconLinkOnPage(url, "meta[name='msapplication-TileImage']", "content", htmldata)) 
      tempIconsArray.push(findIconLinkOnPage(url, "meta[property='og:image']", "content", htmldata))
    rescue
      puts "error reading url"
    end
    
    tempIconsArray.each do |icon|
      icons.push(icon) if icon
    end
    
    return icons
    
  end
  
  def getImageInfoFromFile(fileUrl, domain)
    
    blob = ImageInfoHelper.getImageBlob(fileUrl)
    
    if blob
      
      imageInfo = ImageInfo.new
      imageInfo.url = fileUrl
      imageInfo.width = blob.columns
      imageInfo.height = blob.rows
      imageInfo.fileFormat = blob.format
      imageInfo.domain = domain
      
      imageInfo.save
    end
        
    return imageInfo
    
  end
  
  #Tries to get a favicon from a specified file location
 
  def findFileAtPath(url, path) 
    
    urlString = url.to_s
    urlString = "#{urlString}/#{path}"
    
    #Account for redirects
    realUrl = NetworkHelper.getRealUrlLocation(urlString)
    
    imageInfo = getImageInfoFromFile(realUrl, url.host)
    
    return imageInfo
    
  end
 
  #Tries to get the favicon from a tag in the head of the HTML page
   
  def findIconLinkOnPage(url, cssTagLink, cssTagAttribute, htmldata)

    begin

      imageInfo = nil
      
      parsedPage = Nokogiri::HTML(htmldata)
      elements = parsedPage.css(cssTagLink)
      
      if elements.size > 0
      
        linkString = elements[0][cssTagAttribute]     
        imageInfo = getImageInfoFromFile(linkString, url.host)
        
      end
      
    rescue
      
      imageInfo = nil
      
    end
      
    return imageInfo
    
  end
  
end