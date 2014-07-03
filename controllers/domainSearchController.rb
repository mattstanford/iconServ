
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
  
  def initialize
      @numberOfSearches = 0
      @icons = Array.new
  end

  def findIconForDomain(searchString)

    getArrayOfAvailableIconsForDomain(searchString) { |iconsArray|
      
      jsonArray = nil
      
      if iconsArray
        jsonArray = {'icons' => iconsArray }.to_json
      else
        jsonArray = [].to_json
      end
      
      yield jsonArray
      
    }
    
  end
  
  #Get an array of available icons availale for this domain
  
  def getArrayOfAvailableIconsForDomain(searchString)
    
    url = NetworkHelper.getValidUrl(searchString)

    if url
      
      iconsArray = ImageInfo.where('domain = ?', url.host)
  
      if iconsArray.size == 0
      
        self.createImageInfoArray(url) { |data| 
          yield data
        }
      
      else
        
        yield iconsArray
  
      end #if icons.size == 0
      
    end  #if url
  end
  
  def createImageInfoArray(url)
    
    begin
      #html = open(url.to_s)
      #htmldata = html.read
      
      req = EM::HttpRequest.new(url.to_s).get :redirects => 1
      req.callback {
      
        searchCallback = Proc.new { |data| 
          
          @numberOfSearches -= 1
       
          @icons.push(data) if data
          
          if @numberOfSearches == 0
    
            yield @icons
            
          end
          
        }
        
        findFileAtPath(url, "favicon.ico", searchCallback)
        findFileAtPath(url, "favicon.ico", searchCallback)
        
        #tempIconsArray.push(findFileAtPath(url, "favicon.ico"))
        #tempIconsArray.push(findIconLinkOnPage(url, "link[rel='shortcut icon']", "href", htmldata))
        #tempIconsArray.push(findIconLinkOnPage(url, "link[rel='icon']", "href", htmldata))
        #tempIconsArray.push(findIconLinkOnPage(url, "link[rel='apple-touch-icon']", "href", htmldata))
        #tempIconsArray.push(findFileAtPath(url, "apple-touch-icon.png"))
        #tempIconsArray.push(findIconLinkOnPage(url, "meta[name='msapplication-TileImage']", "content", htmldata)) 
        #tempIconsArray.push(findIconLinkOnPage(url, "meta[property='og:image']", "content", htmldata))
      }
      req.errback {
        yield @icons
      }
    rescue
      puts "error reading url"
      yield @icons
    end
    
  end
  
  def getImageInfoFromFile(fileUrl, domain)
    
    ImageInfoHelper.getImageBlob(fileUrl) { |blob| 
    
      imageInfo = nil
    
      if blob
        
        imageInfo = ImageInfo.new
        imageInfo.url = fileUrl
        imageInfo.width = blob.columns
        imageInfo.height = blob.rows
        imageInfo.fileFormat = blob.format
        imageInfo.domain = domain
        
        imageInfo.save
      end
      
      yield imageInfo
    }
    
  end
  
  #Tries to get a favicon from a specified file location
 
  def findFileAtPath(url, path, myBlock) 
    
    @numberOfSearches += 1
    
    urlString = url.to_s
    urlString = "#{urlString}/#{path}"
    
    #Account for redirects

    getImageInfoFromFile(urlString, url.host) { |imageInfo| myBlock.call(imageInfo) }
    

    
  end
 
  #Tries to get the favicon from a tag in the head of the HTML page
   
  def findIconLinkOnPage(url, cssTagLink, cssTagAttribute, htmldata)

    begin

      @numberOfSearches += 1
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