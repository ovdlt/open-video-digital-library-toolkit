require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Download do
  before(:each) do
    @valid_attributes = {
      :user_id => 1,
      :video_id => 1,
    }
  end

  it "should create a new instance given valid attributes" do
    Download.create!(@valid_attributes)
  end
end
