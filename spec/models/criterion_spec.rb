require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Criterion do

  describe "all critera" do
  end

  describe "unsaved critera" do
  end

  describe "saved criteria" do

    before(:each) do
      @search = Search.create! :user_id => 1
      @valid_attributes = {
        :search => @search,
      }
    end

    it "should create a new instance given valid attributes" do
      Criterion.create!(@valid_attributes)
    end

  end

end
