require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Video, "::VIDEO_DIR" do
  it "should be a well formed path to an existing path" do
    File.directory?(Video::VIDEO_DIR).should be_true
  end
end

describe Video, ".list_videos" do
  before(:all) do
    @video = File.open("#{Video::VIDEO_DIR}/funny_video.fla", "w") { |f| f << "some stuff" }
    @video_list = Video.list_videos
    @video_item = @video_list.select{|v| v[:filename] == "funny_video"}.first
  end
  
  it "should return an array of hashes" do
    @video_list.should       be_instance_of(Array)
    @video_list.first.should be_instance_of(Hash)
  end
  
  it "should know the filename" do
    @video_item[:filename].should == "funny_video"
  end
  
  it "should know the type" do
    @video_item[:type].should == ".fla"
  end
  
  it "should know the size" do
    @video_item[:size].should == 10
  end
  
  it "should put directories first" do
    @video_list.first[:type].should be_blank
    @video_list.last[:type].should_not be_blank
    @video_list.partition {|file| file[:type].blank? }.flatten.should == @video_list
  end
  
  after(:all) do
    File.delete @video.path
  end
end