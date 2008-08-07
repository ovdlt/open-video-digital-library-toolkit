require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  it "should use HomeController" do
    controller.should be_an_instance_of(HomeController)
  end

  describe "#index" do

    before(:each) { get :index }

    it "should render most recent videos by default" do
      response.should be_success
      response.should render_template("home/recent")
    end

  end

end
