require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BookmarksController do

  #Delete this example and add some real ones
  it "should use BookmarksController" do
    controller.should be_an_instance_of(BookmarksController)
  end

  describe "ordering" do

    it "should require login" do
      put :order, :order => "1 2, 3"
      response.should be_missing
    end

    it "should require all items owned user" do
      login_as_3
      put :order, :order => "1 8"
      response.should be_missing
    end

    it "should reorder the list" do
      login_as_3

      Collection.find(1).all_videos.map(&:id).should == [ 1, 2, 3, 4, 5 ]
      Collection.find(1).all_bookmarks.map(&:id).should == [ 2, 1, 3, 4, 5 ]

      put :order, :order => [ 2, 1, 3, 4, 5 ].reverse.join(" ")
      response.should be_success

      Collection.find(1).all_videos.map(&:id).should == [ 1, 2, 3, 4, 5 ].reverse
      Collection.find(1).all_bookmarks.map(&:id).should == [ 2, 1, 3, 4, 5 ].reverse
    end

  end

end
