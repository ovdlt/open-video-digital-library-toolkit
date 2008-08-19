require 'faker'

Factory.sequence :filename do |n|
  filename = "temp_video_#{n}.mov"
  create_temp_video filename
  filename
end

Factory.define :video do |v|
  v.title       { ( Faker::Lorem.words.sort { rand } ).join(" ").capitalize }
  v.filename    { Factory.next :filename }
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
  v.size        { rand(16.megabytes) }
end
