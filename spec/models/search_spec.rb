require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Search do

  describe "all searches" do

    before(:each) do
      @search = Search.new
    end

    it "should add critera" do
    end

  end

  describe "unsaved searches" do

    before(:each) do
      @valid_attributes = {
      }
    end

    it "should create a new instance given valid attributes" do
      Search.new(@valid_attributes)
    end

  end

  describe "saved searched" do

    before(:each) do
      @valid_attributes = {
        :user_id => 1,
      }
    end

    it "should create a new instance given valid attributes" do
      Search.create!(@valid_attributes)
    end

    it "should refuse to save if it doesn't have a user_id" do
      @valid_attributes.delete :user_id
      Search.create(@valid_attributes).valid?.should be_false
    end

  end

end
