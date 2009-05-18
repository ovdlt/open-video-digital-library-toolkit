require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Collection do
  before(:each) do
    @valid_attributes = {
      :title => "foo",
      :user_id => 1,
    }
  end

  it "should create a new instance given valid attributes" do
    Collection.create!(@valid_attributes)
  end

  describe "featured" do

    it "should return the collections" do
      Collection.featured.map(&:id).should == [ 4, 3, 2, 1 ]
    end

    it "should reorder the whole collection" do
      Collection.featured.map(&:id).should == [ 4, 3, 2, 1 ]
      Collection.featured_order =  [ 1, 2, 3, 4 ]
      Collection.featured.map(&:id).should == [ 1, 2, 3, 4 ]
    end

    it "should reorder the beginning of the collection" do
      Collection.featured.map(&:id).should == [ 4, 3, 2, 1 ]
      Collection.featured_order = [ 3, 4 ]
      Collection.featured.map(&:id).should ==  [ 3, 4, 2, 1 ]
    end

    it "should reorder the end of the collection" do
      Collection.featured.map(&:id).should == [ 4, 3, 2, 1 ]
      Collection.featured_order = [ 1, 2 ]
      Collection.featured.map(&:id).should == [ 4, 3, 1, 2 ]
    end

    it "should reorder the middle of the collection" do
      Collection.featured.map(&:id).should == [ 4, 3, 2, 1 ]
      Collection.featured_order = [ 2, 3 ]
      Collection.featured.map(&:id).should == [ 4, 2, 3, 1 ]
    end

    it "should reorder aribtrarilty collection" do
      Collection.featured.map(&:id).should == [ 4, 3, 2, 1 ]
      Collection.featured_order =  [ 1, 4 ]
      Collection.featured.map(&:id).should == [ 1, 3, 2, 4 ]
    end

  end

end
