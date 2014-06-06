class CreateImageInfo < ActiveRecord::Migration
  
  def up
    create_table :image_infos do |t|
      t.string :url
      t.integer :width
      t.integer :height
      t.string :fileFormat
    end
    
  end
  
  def down
    drop_table :imageInfo
  end

end
