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
      assigns[:video].should be_an_instance_of(Video)
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
  
  # describe "#new, when the filename parameter is invalid, eg: %0C"
  
  describe "#create with valid params" do
    before(:all) do
      create_temp_video("cute_with_chris.fla")
    end
    
    def do_post
      post :create, :video => {:filename => "cute_with_chris.fla", :title => "teen cult machine", :sentence => "all your dreams are dead"}
    end
    
    it "should make a new video" do
      lambda { do_post }.should change(Video, :count).by(1)
    end
    
    it "should redirect to the videos index" do
      do_post
      response.should be_redirect
      response.should redirect_to(videos_path)
    end
    
    it "should set the flash" do
      do_post
      flash[:notice].should_not be_blank
    end
  end
  
  describe "#create when the file does not exist" do
    before(:each) do
      # note, no before(:all) this time
      post :create, :video => {:filename => "this file is not there", :title => "teen cult machine", :sentence => "all your dreams are dead"}
    end
    
    it "should not cause a 500 server error response" do
      response.should_not be_error
    end
    
    it "should display the new page with the fields populated and with errors" do
      response.should be_success
      response.body.should == "videos/new"
      assigns[:video].errors.should_not be_empty
    end
  end
  
  describe "#create with invalid params" do
    before(:all) do
      create_temp_video("cute_with_chris.fla")
    end
    
    def do_post
      post :create, :video => {:filename => "cute_with_chris.fla", :title => "", :sentence => "all your dreams are dead"}
    end
    
    it "should not make a new video" do
      lambda { do_post }.should_not change(Video, :count)
    end
    
    it "should display the new page with the fields populated and with errors" do
      do_post
      response.should be_success
      response.body.should == "videos/new"
      assigns[:video].errors.should_not be_empty
    end
  end
end
