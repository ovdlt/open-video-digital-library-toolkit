require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Video, "::VIDEO_DIR" do
  it "should be a well formed path to an existing path" do
    File.directory?(Video::VIDEO_DIR).should be_true
  end
end

describe Video, ".list_videos" do
  before(:all) do
    @video = File.open(File.join(Video::VIDEO_DIR, "funny_video.fla"), "w") { |f| f << "some stuff" }
    @video_list = Video.list_videos
    @video_item = @video_list.select{|v| v.path =~ /funny_video/}.first
  end
  
  it "should return an array of Files" do
    @video_list.should       be_instance_of(Array)
    @video_list.first.should be_instance_of(File)
  end
  
  it "should put directories first" do
    @video_list.first.stat.should be_directory
    @video_list.last.stat.should_not be_directory
    @video_list.partition {|file| file.stat.directory? }.flatten.should == @video_list
  end
  
  after(:all) do
    File.delete @video.path
  end
end