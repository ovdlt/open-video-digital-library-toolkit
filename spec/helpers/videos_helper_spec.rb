require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe VideosHelper, "#file_size(file)" do
  before(:all) do
    @video = File.open(File.join(RAILS_ROOT, "tmp", "some_file"), "w") { |f| f << "0123456789" * 1024 }
    @video = File.new(@video.path) # otherwise we can't do anything with the file
  end
  
  after(:all) do
    File.delete @video.path
  end
  
  it "should return the file size in humanized bytes if it's a file" do
    helper.file_size(@video).should == "10 KB"
  end
  
  it "should return nil if it's a directory" do
    helper.file_size(File.new(File.join(RAILS_ROOT))).should be_nil
  end
end

describe VideosHelper, "#link_to_add_video(file)" do
  before(:each) do
    File.open(videos(:our_mr_sun).path, "w") { |f| f << "0123456789" } unless File.exists?(videos(:our_mr_sun).path)
    @new_file_path = File.join(Video::VIDEO_DIR, "l_is_for_labour.fla")
    File.open(@new_file_path, "w") { |f| f << "01234567892" } unless File.exists?(@new_file_path)
  end
  
  after(:all) do
    File.delete videos(:our_mr_sun).path
    File.delete @new_file_path
  end
  
  it "should return nil if the file is already a cataloged video (by file path)" do
    helper.link_to_add_video(File.new(videos(:our_mr_sun).path)).should be_nil
  end
  
  it "should return a link to /videos/new if the file is not already cataloged" do
    html = helper.link_to_add_video(File.new(@new_file_path))
    html.should have_tag("a[href*=?]", new_video_path, true)
  end
  
  it "should return nil if the file is a directory" do
    helper.link_to_add_video(File.new(RAILS_ROOT)).should be_nil
  end
end
