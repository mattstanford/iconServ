
require "em-http-request"
require_relative 'networkHelper'

class ImageInfoHelper
    
  def self.getImageBlob(fileUrl)
    
    begin
      # Get the file type by getting the string after the last "."
      fileFormat = fileUrl.split('.').last
      
      #Get data from the network
      req = EM::HttpRequest.new(fileUrl).get :redirects => 1
      req.callback {
        
        #Read in the image using the RMagick library
        image = Magick::ImageList.new
        imageBlob = req.response
        
        begin
          image.from_blob(imageBlob){self.format=fileFormat}
        rescue
          puts "Blob not found"
          image = nil
        end
        
        
        yield image
        
      }
      req.errback {
        yield nil
      }
      
    rescue
      yield nil
    end
    
    #return image
    
  end
    
end