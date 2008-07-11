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
