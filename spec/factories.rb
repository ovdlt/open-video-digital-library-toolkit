require 'faker'

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
  v.assets do
    asset = Asset.new :uri => "file:///" + Factory.next( :filename ),
                       :size => rand(16.megabytes)
    [ asset ]
  end
end
