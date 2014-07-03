
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

      req = EM::HttpRequest.new(url.to_s).get :redirects => 1
      req.callback {
      
        searchCallback = Proc.new { |data| 
          
          @numberOfSearches -= 1
       
          @icons.push(data) if data
          
          if @numberOfSearches == 0
    
            yield @icons
            
          end
          
        }
        htmldata = req.response
        
        findFileAtPath(url, "favicon.ico", searchCallback)
        findIconLinkOnPage(url, "link[rel='shortcut icon']", "href", htmldata, searchCallback)
        findIconLinkOnPage(url, "link[rel='icon']", "href", htmldata, searchCallback)
        findIconLinkOnPage(url, "link[rel='apple-touch-icon']", "href", htmldata, searchCallback)
        findFileAtPath(url, "apple-touch-icon.png", searchCallback)
        findIconLinkOnPage(url, "meta[name='msapplication-TileImage']", "content", htmldata, searchCallback)
        findIconLinkOnPage(url, "meta[property='og:image']", "content", htmldata, searchCallback)
       
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
        
        begin
        
          imageInfo = ImageInfo.new
          imageInfo.url = fileUrl
          imageInfo.width = blob.columns
          imageInfo.height = blob.rows
          imageInfo.fileFormat = blob.format
          imageInfo.domain = domain
          
          imageInfo.save
          
        rescue
          
          yield nil
          
        end
      end
      
      yield imageInfo
    }
    
  end
  
  #Tries to get a favicon from a specified file location
 
  def findFileAtPath(url, path, callback) 
    
    @numberOfSearches += 1
    
    urlString = url.to_s
    urlString = "#{urlString}/#{path}"
    
    #Account for redirects

    getImageInfoFromFile(urlString, url.host) { |imageInfo| callback.call(imageInfo) }
    

    
  end
 
  #Tries to get the favicon from a tag in the head of the HTML page
   
  def findIconLinkOnPage(url, cssTagLink, cssTagAttribute, htmldata, callback)

    begin

      @numberOfSearches += 1
      
      parsedPage = Nokogiri::HTML(htmldata)
      elements = parsedPage.css(cssTagLink)
      
      if elements.size > 0
      
        linkString = elements[0][cssTagAttribute]     
        #imageInfo = getImageInfoFromFile(linkString, url.host)
        getImageInfoFromFile(linkString, url.host) { |imageInfo| callback.call(imageInfo) }
      
      else
        
        callback.call(nil)
      
      end
      
    rescue
      
      callback.call(nil)
      
    end
    
  end
  
end