class DropVideoYear < ActiveRecord::Migration
  def self.up

    if ( creation = PropertyType.find_by_name "Creation" )
      Video.find(:all).each do |video|
        if !video.properties.find_by_property_type_id( creation.id )
          if !video.year.blank?
            day = rand(365)
            date = Date.ordinal( video.year.to_i, day )
            video.properties << Property.new( :property_type => creation, :date_value => date )
            video.save!
          end
        end
      end
    end

    remove_column :videos, :year
  end
  def self.down
    add_column :videos, :year, :string, :limit => 4, :null => true
  end
end
