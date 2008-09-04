require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SavedQuery do

  describe "#create" do

    before(:each) do
      @valid_attributes = {
        :user_id => 1,
        :descriptor_id => 1,
        :query_string => "foo bar"
      }
    end

    it "should create a new instance given valid attributes" do
      SavedQuery.create!(@valid_attributes)
    end

    it "should require a user_id" do
      @valid_attributes.delete :user_id
      SavedQuery.create(@valid_attributes).save.should be_false
    end

    it "should require a descriptor if no query" do
      @valid_attributes.delete :query_string
      SavedQuery.create(@valid_attributes).save.should be_true
      @valid_attributes.delete :descriptor_id
      SavedQuery.create(@valid_attributes).save.should be_false
    end

    it "should require a query if no descriptor" do
      @valid_attributes.delete :descriptor_id
      SavedQuery.create(@valid_attributes).save.should be_true
      @valid_attributes.delete :query_string
      SavedQuery.create(@valid_attributes).save.should be_false
    end

  end

end
