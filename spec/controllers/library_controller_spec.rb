require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LibraryController do

  it "should use LibraryController" do
    controller.should be_an_instance_of(LibraryController)
  end

  describe ":show" do

    it "should require the user to be logged in" do
      get :show
      response.should redirect_to( login_path )
    end

    it "should require the user be an admin" do
      login_as_user
      get :show
      response.should be_missing
    end

    it "should render the library page with an assign" do
      login_as_admin
      get :show
      response.should be_success
      response.should render_template( "library/show" )
      (Library === assigns[:library]).should be_true
    end

    it "should render the library page with an assign" do
      login_as_admin
      get :show
      response.should be_success
      response.should render_template( "library/show" )
      (Library === assigns[:library]).should be_true
    end

  end

  describe ":update" do

    before(:each) do
      login_as_admin
    end

    it "should require the user to be logged in" do
      logout
      post :create
      response.should redirect_to( login_path )
    end

    it "should require the user be an admin" do
      login_as_user
      post :create
      response.should be_missing
    end

    it "should allow a post by the admin" do
      post :update
      (Library === assigns[:library]).should be_true
      response.should render_template( "library/show" )
    end

    it "should not change anything if the params don't change" do
      l = Library.find :first
      post :update
      l.should == Library.find(:first)
    end

  end

end
