require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SavedQueriesController do

  it "should use SavedQueriesController" do
    controller.should be_an_instance_of(SavedQueriesController)
  end

  describe "#create when not logged in" do

    it "should require the user to be logged in" do
      prev = "http://test.host/previous/page"
      request.env["HTTP_REFERER"] = prev
      post :create
      flash[:error].should match(/logged in/)
      response.should redirect_to(prev)
    end

  end

  describe "#create when logged in" do

    before(:each) do
      login_as_user
      @prev = "http://test.host/previous/page"
      request.env["HTTP_REFERER"] = @prev
    end

    # we no longer require this; parameters could be empty anyway
#     it "should require some parameters" do
#       lambda { post :create }.should_not \
#         change { current_user.searches.size }
#       flash[:error].should match(/error/i)
#       response.should redirect_to(@prev)
#     end

    it "should add saved query given a string" do
      lambda { post :create, "search[criteria][text][]" => "foo" }.should \
        change { current_user.reload; current_user.searches.size }.by(1)
      flash[:notice].should match(/saved/)
    end

    it "should add saved query given a descriptor" do
      lambda { post :create, :descriptor_value_id => 1 }.should \
        change { current_user.reload; current_user.searches.size }.by(1)
      flash[:notice].should match(/saved/)
    end

  end

  describe "#destroy when not logged in" do

    before(:each) do
      login_as_user
      @search = Search.create! :user_id => current_user.id,
                                :text => "some words"
    end

    it "should require the user be logged in" do
      logout
      delete :destroy, :id => @search.id
      response.response_code.should == 404
    end

  end

  describe "#destroy when logged in" do

    before(:each) do
      login_as_user
      @prev = "http://test.host/previous/page"
      request.env["HTTP_REFERER"] = @prev
      @search = Search.create! :user_id => current_user.id,
                                :text => "some words"
    end

    it "should require a parameter" do
      lambda { delete :destroy }.should \
        raise_error( ActionController::RoutingError )
    end

    it "should require a valid parameter" do
      delete :destroy, :id => 0
      response.response_code.should == 404
    end

    it "should require the user own the search" do
      login_as_other_user
      delete :destroy, :id => @search.id
      response.response_code.should == 404
    end

    it "should delete the query" do
      lambda { delete :destroy, :id => @search.id }.should \
        change { current_user.reload; current_user.searches.size }.by(-1)
      flash[:notice].should match(/deleted/i)
      response.should redirect_to(@prev)
    end

  end

end


