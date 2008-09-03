require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AssetsHelper do

  describe "#file_size(file)" do
    before(:each) do
      @asset = create_temp_asset("the_doctor_dances.avi", 10.kilobytes)
    end
  
    after(:each) do
      File.unlink @asset.path
    end

    it "should return the file size in humanized bytes if it's a file" do
      helper.file_size(@asset).should == "10 KB"
    end
  
    it "should return nil if it's a directory" do
      helper.file_size(File.new(File.join(RAILS_ROOT))).should be_nil
    end

  end

  describe "#file_ext(file)" do
    before(:each) do
      @asset = create_temp_asset("the_doctor_dances.avi", 10.kilobytes)
    end
  
    after(:each) do
      File.unlink @asset.path
    end

    it "should return the ext cap'd" do
      helper.file_ext(@asset).should == "AVI"
    end
  
  end

end
