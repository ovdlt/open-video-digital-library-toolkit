require 'faker'
begin
require 'factory_girl'
rescue Exception => e
pp e.backtrace
raise
end

Factory.sequence :filename do |n|
  filename = "temp_video_#{n}.mov"
  create_temp_asset filename
  filename
end

Factory.define :video do |v|

  v.title       { ( Faker::Lorem.words.sort { rand } ).join(" ").capitalize }

  v.sentence    do
    v = (( Faker::Lorem.words( 15 ).sort { rand } ).join(" ")+".").capitalize
    v += " acommonword"
    r = rand
    if rand < 0.4
      v += " forty"
    end        
    if rand < 0.7
      v += " seventy"
      v += " seven"
    end        
    v
  end  

  v.rights_id {
    # rand(Rights.count) + 1
    1
  }

  v.properties do
    [  Property.build( "Rights Statement", 1 ) ]
  end


  v.assets do |v|
    asset = Asset.new :uri => "file:///" + Factory.next( :filename ),
                       :size => rand(16.megabytes)
    [ asset ]
  end

end
