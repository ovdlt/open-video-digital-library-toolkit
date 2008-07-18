require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe VideosHelper, "#file_size(file)" do
  before(:each) do
    @video = create_temp_video("the_doctor_dances.avi", 10.kilobytes)
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
    @our_mr_sun = Factory(:video)
    @video = create_temp_video("l_is_for_labour")
  end
  
  it "should return nil if the file is already a cataloged video (by file path)" do
    file = File.new(@our_mr_sun.path)
    helper.link_to_add_video(file).should be_nil
  end
  
  it "should return a link to /videos/new if the file is not already cataloged" do
    html = helper.link_to_add_video(@video)
    html.should have_tag("a[href*=?]", new_video_path, true)
  end
  
  it "should return nil if the file is a directory" do
    helper.link_to_add_video(File.new(RAILS_ROOT)).should be_nil
  end
end
