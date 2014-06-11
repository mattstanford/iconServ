
#class MyApp < Sinatra::Application
class ImageInfoHelper
    
  def self.getImageBlob(fileUrl)
    
    begin
      # Get the file type by getting the string after the last "."
      fileFormat = fileUrl.split('.').last
      
      #Read in the image using the RMagick library
      image = Magick::ImageList.new
      imageBlob = open(fileUrl)
      image.from_blob(imageBlob.read){self.format=fileFormat}
    rescue
      image = nil
    end
    
    return image
    
  end
    
end