namespace :db do

  desc "load database with [number] lorem ipsum test videos"
  task :populate, [ :number ] => :environment do |t,args|

    require File.expand_path(File.join(RAILS_ROOT,"spec","factories"))
    require File.expand_path(File.join(RAILS_ROOT,"spec","video_helper"))
    require File.expand_path(File.join(RAILS_ROOT,"spec","asset_helper"))

    types = begin
              dvs = DescriptorValue.find(:all)
              dts = dvs.map(&:property_type).uniq
            end

    values = []
    types.each do |type|
      values[type.id] =
        DescriptorValue.find_all_by_property_type_id(type.id).to_a
    end

    # DANGEROUS!

    assets = Asset.find :all, :conditions => "uri like '%/temp_video_%'"
    
    assets.each do |asset|
      if asset.video
        asset.video.destroy
      else
        asset.destroy
      end
    end
    
    number = args.number
    number ||= 100
    number = number.to_i

    years = (1850..2008).to_a

    collections = Collection.find_all_by_user_id 10

    # generate videos

    creation = PropertyType.find_by_name "Creation"

    number.times do
      v = Factory(:video)
      
      if creation
        y = years[rand(years.size)]
        d = 1+rand(364)
        date = Date::ordinal( y, d )
        v.properties << Property.new( :property_type_id => creation.id, :date_value => date )
      end

      types.each do |type|
        v.properties << values[type.id][ rand(values[type.id].size) ]
      end
      v.duration = rand(3*60*60)

      c = collections[rand(collections.size)]
      c.all_videos << v
      c.save!
      v.save!
    end

    # generate uncatagorized files
    number.times do
      Factory.next :filename
    end

  end
end
