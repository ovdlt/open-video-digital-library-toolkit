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
end
