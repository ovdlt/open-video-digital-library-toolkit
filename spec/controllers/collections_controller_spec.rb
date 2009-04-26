require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CollectionsController do

  #Delete this example and add some real ones
  it "should use CollectionsController" do
    controller.should be_an_instance_of(CollectionsController)
  end

  describe "featured order" do

    it "should require login" do
      put :featured_order, :order => "1 2, 3"
      response.should redirect_to login_path
    end

    it "should not allow user" do
      login_as_user
      put :featured_order, :order => "1 2, 3"
      response.should be_missing
    end

    it "should not allow cataloger" do
      login_as_cataloger
      put :featured_order, :order => "1 2, 3"
      response.should be_missing
    end

    it "should the list" do
      login_as_admin
      Collection.featured.map(&:id).should == [ 4, 3, 2, 1 ]
      
      put :featured_order, :order => "1 2, 3  4"
      response.should be_success

      Collection.featured.map(&:id).should == [ 1, 2, 3, 4 ]
    end

  end

end
