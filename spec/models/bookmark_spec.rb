require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Bookmark do
  before(:each) do
    @valid_attributes = {
      :collection => Collection.create!( :title => "foo", :user_id => 5 ),
      :video_id => 1,
    }
  end

  it "should create a new instance given valid attributes" do
    Bookmark.create!(@valid_attributes)
  end

  describe "ordered" do

    it "should return the collections" do
      Collection.find(1).all_videos.map(&:id).should == [ 1, 2, 3, 4, 5 ]
      Collection.find(1).all_bookmarks.map(&:id).should == [ 2, 1, 3, 4, 5 ]
    end

    it "should reject if videos don't match user" do
      Bookmark.set_order( 5, [ 1, 2, 3, 4, 5 ] ).should be_false
    end

    it "should reorder the whole collection" do
      Bookmark.set_order 3, [ 2, 1, 3, 4, 5 ].reverse

      Collection.find(1).all_videos.map(&:id).should == [ 1, 2, 3, 4, 5 ].reverse
      Collection.find(1).all_bookmarks.map(&:id).should == [ 2, 1, 3, 4, 5].reverse
    end

    it "should reorder the beginning of the collection" do
      Bookmark.set_order 3, [ 3, 2, 1 ]

      Collection.find(1).all_videos.map(&:id).should == [ 3, 1, 2, 4, 5 ]
      Collection.find(1).all_bookmarks.map(&:id).should == [ 3, 2, 1, 4, 5 ]
    end

    it "should reorder the end of the collection" do
      Bookmark.set_order 3, [ 5, 4, 3 ]

      Collection.find(1).all_videos.map(&:id).should == [ 1, 2, 5, 4, 3  ]
      Collection.find(1).all_bookmarks.map(&:id).should == [ 2, 1, 5, 4, 3  ]
    end

    it "should reorder the middle of the collection" do
      Bookmark.set_order 3, [ 2, 1, 4, 5, 3 ]

      Collection.find(1).all_videos.map(&:id).should == [ 1, 2, 4, 5, 3  ]
      Collection.find(1).all_bookmarks.map(&:id).should == [ 2, 1, 4, 5, 3 ]
    end

    it "should reorder aribtrarilty collection" do
      Bookmark.set_order 3, [ 5, 2, 4 ]

      Collection.find(1).all_videos.map(&:id).should == [ 5, 2, 3, 1, 4 ]
      Collection.find(1).all_bookmarks.map(&:id).should == [ 5, 1, 3, 2, 4 ]
    end

  end

end
