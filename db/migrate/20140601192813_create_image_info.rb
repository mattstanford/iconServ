class CreateImageInfo < ActiveRecord::Migration
  
  def up
    create_table :imageInfo do |t|
      t.string :domainName
      t.integer :width
      t.integer :height
      t.string :type
    end
    
  end
  
  def down
    drop_table :imageInfo
  end

end
