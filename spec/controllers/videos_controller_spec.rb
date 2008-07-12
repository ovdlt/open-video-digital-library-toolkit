require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe VideosController do
  describe "#index" do
    before(:each) do
      get :index
    end
    
    it "should assign @videos" do
      assigns[:videos].should_not be_nil
      assigns[:videos].should be_an_instance_of(Array)
    end
    
    it "should return a successful response" do
      response.should be_success
    end
  end
  
  describe "#new, when the filename parameter is a valid filename with no directory information" do
    before(:each) do
      @filename = "a_great_video.mov"
      get :new, :filename => @filename
    end
    
    it "should return a successful response" do
      response.should be_success
    end
    
    it "should assign @video to a new instance of Video with its filename prepopulated from the params" do
      assigns[:video].should_not be_nil
      assigns[:video].should be_an_instance_of(Video
      assigns[:video].should be_new_record
      assigns[:video].filename.should == @filename
    end
  end
  
  describe "#new, when the filename parameter refers to a file outside the videos directory" do    
    it "should return a 404" do
      get :new, :filename => '../README.md'
      response.should be_missing
    end
  end
  
  # describe "#new, when the filename parameter is invalid"
end
