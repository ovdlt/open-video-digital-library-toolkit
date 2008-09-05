namespace :db do

  desc "load database with [number] lorem ipsum test videos"
  task( { :populate => :environment }, :number ) do |t,args|

    require File.expand_path(File.join(RAILS_ROOT,"spec","factories"))
    require File.expand_path(File.join(RAILS_ROOT,"spec","video_helper"))
    require File.expand_path(File.join(RAILS_ROOT,"spec","asset_helper"))

    types = DescriptorType.find( :all ).to_a
    values = []
    types.each do |type|
      values[type.id] = type.descriptors.to_a
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

    # generate videos
    number.times do
      v = Factory(:video)
      v.year = years[rand(years.size)]
      types.each do |type|
        v.descriptors << values[type.id][ rand(values[type.id].size) ]
      end
      v.duration = rand(3*60*60)
      v.save!
    end

    # generate uncatagorized files
    number.times do
      Factory.next :filename
    end

  end

end
