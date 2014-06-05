class AddDomainToImageinfos < ActiveRecord::Migration  
  def change
    add_column :image_infos, :domain, :string
  end
end
