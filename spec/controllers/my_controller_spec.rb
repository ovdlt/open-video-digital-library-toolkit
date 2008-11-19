require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MyController do

  describe "#show" do

    it "should require the user to be logged in" do
      get :show
      response.should redirect_to(login_path)
    end

    it "should render show if logged in" do
      login_as_user
      get :show
      response.should redirect_to(home_my_path)
    end


  end

end
