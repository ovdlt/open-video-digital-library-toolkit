require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Priority do
  before(:each) do
    @valid_attributes = {
      :object_id => 1,
      :priority => 10,
    }
  end

  it "should create a new instance given valid attributes" do
    Priority.create!(@valid_attributes)
  end
end
