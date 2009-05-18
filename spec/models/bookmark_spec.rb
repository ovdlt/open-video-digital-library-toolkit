require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Bookmark do
  before(:each) do
    @valid_attributes = {
      :collection => Collection.create!( :title => "foo", :user_id => 1 ),
      :video_id => 1,
    }
  end

  it "should create a new instance given valid attributes" do
    Bookmark.create!(@valid_attributes)
  end

  describe "ordered" do

    it "should return the collections" do
      Collection.find(1).all_videos.map(&:id).should == [ 1, 2, 3, 4, 5, 6, 7 ]
      Collection.find(1).all_bookmarks.map(&:id).should == [ 2, 1, 3, 4, 5, 6, 7 ]
    end

    it "should reject if videos don't match user" do
      Bookmark.set_order( 1, [ 1, 2, 3, 4, 5, 6, 7 ] ).should be_false
    end

    it "should reorder the whole collection" do
      Bookmark.set_order 10, [ 2, 1, 3, 4, 5, 6, 7 ].reverse

      Collection.find(1).all_videos.map(&:id).should == [ 1, 2, 3, 4, 5, 6, 7 ].reverse
      Collection.find(1).all_bookmarks.map(&:id).should == [ 2, 1, 3, 4, 5, 6, 7 ].reverse
    end

    it "should reorder the beginning of the collection" do
      Bookmark.set_order 10, [ 3, 2, 1 ]

      Collection.find(1).all_videos.map(&:id).should == [ 3, 1, 2, 4, 5, 6, 7 ]
      Collection.find(1).all_bookmarks.map(&:id).should == [ 3, 2, 1, 4, 5, 6, 7 ]
    end

    it "should reorder the end of the collection" do
      Bookmark.set_order 10, [ 7, 6, 5 ]

      Collection.find(1).all_videos.map(&:id).should == [ 1, 2, 3, 4, 7, 6, 5 ]
      Collection.find(1).all_bookmarks.map(&:id).should == [ 2, 1, 3, 4, 7, 6, 5 ]
    end

    it "should reorder the middle of the collection" do
      Bookmark.set_order 10, [ 2, 1, 4, 5, 3, 6, 7 ]

      Collection.find(1).all_videos.map(&:id).should == [ 1, 2, 4, 5, 3, 6, 7 ]
      Collection.find(1).all_bookmarks.map(&:id).should == [ 2, 1, 4, 5, 3, 6, 7 ]
    end

    it "should reorder aribtrarilty collection" do
      Bookmark.set_order 10, [ 7, 2, 4 ]

      Collection.find(1).all_videos.map(&:id).should == [ 7, 2, 3, 1, 5, 6, 4 ]
      Collection.find(1).all_bookmarks.map(&:id).should == [ 7, 1, 3, 2, 5, 6, 4 ]
    end

  end

end
