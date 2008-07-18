# Factory.sequence :filename do |n|
#   filename = "temp_video_#{n}.mov"
#   create_temp_video filename
#   filename
# end

Factory.define :video do |v|
  v.title    "Our Mr. Sun"
  # v.filename { Factory.next :filename }
  v.filename do
    filename = "temp_video_our_mr_sun.mov"
    create_temp_video filename
    filename
  end
  v.sentence "This film describes the sun in scientific but entertaining terms."
  v.size     261.megabytes
end