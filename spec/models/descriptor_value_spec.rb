require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DescriptorValue do
  before(:each) do
    type = DescriptorType.create! :title => "some title"
    @valid_attributes = {
      :descriptor_type_id => type.id,
      :text => "some descriptor value"
    }
  end

  it "should create a new instance given valid attributes" do
    DescriptorValue.create!(@valid_attributes)
  end
end
