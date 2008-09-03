require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AssetsHelper do

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
