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

describe Video do
  it "should be able to tell you its full path" do
    videos(:our_mr_sun).path.should == File.join(Video::VIDEO_DIR, videos(:our_mr_sun).filename)
  end
end


describe Video, "#valid_path?" do
  it "should return true if the file's path is in the videos directory" do
    video = Video.new(:filename => "a_normal_video.mov")
    video.should be_valid_path
  end
  
  it "should return false if the file's path is outside the videos directory" do
    video = Video.new(:filename => File.join("..", "..", "something_outside.mov"))
    video.should_not be_valid_path
  end
end

describe Video, "filename=" do
  it "should the video dir to the path" do
    video = Video.new
    video.filename = ''
    video.filename.should == Video::VIDEO_DIR
  end

  it "should sanitize the path by expanding the file name to the absolute pathname" do
    video = Video.new
    video.filename = File.join("..", "app", "..", "spec", "..")
    video.filename.should == RAILS_ROOT
  end
  
  it "should also work when set with new attributes" do
    video = Video.new(:filename => File.join("..", "app", "..", "spec", ".."))
    video.filename.should == RAILS_ROOT
  end
end