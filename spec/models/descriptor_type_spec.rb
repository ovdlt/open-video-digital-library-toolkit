require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DescriptorType do
  before(:each) do
    @valid_attributes = {
      :title => "some descriptor"
    }
  end

  it "should create a new instance given valid attributes" do
    DescriptorType.create!(@valid_attributes)
  end
end
