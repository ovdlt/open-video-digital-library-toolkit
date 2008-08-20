require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AssetsHelper, "#file_size(file)" do
  before(:each) do
    @asset = create_temp_asset("the_doctor_dances.avi", 10.kilobytes)
  end
  
  it "should return the file size in humanized bytes if it's a file" do
    helper.file_size(@asset).should == "10 KB"
  end
  
  it "should return nil if it's a directory" do
    helper.file_size(File.new(File.join(RAILS_ROOT))).should be_nil
  end
end

describe AssetsHelper, "#link_to_add_asset(file)" do
  before(:each) do
    @our_mr_sun = Factory(:video).assets[0]
    @asset = create_temp_asset("l_is_for_labour")
  end
  
  it "should return nil if the file is already a cataloged asset (by file path)" do
    file = File.new(@our_mr_sun.path)
    helper.link_to_add_asset(file).should be_nil
  end
  
  it "should return a link to /videos/new if the file is not already cataloged" do
    html = helper.link_to_add_asset(@asset)
    html.should have_tag("a[href*=?]", new_video_path, true)
  end
  
  it "should return nil if the file is a directory" do
    helper.link_to_add_asset(File.new(RAILS_ROOT)).should be_nil
  end
end
