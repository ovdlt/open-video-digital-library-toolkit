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
    rand(Rights.count) + 1
  }
  v.assets do
    asset = Asset.new :uri => "file:///" + Factory.next( :filename ),
                       :size => rand(16.megabytes)
    [ asset ]
  end
end
