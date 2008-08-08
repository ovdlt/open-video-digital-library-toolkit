require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Descriptor do
  before(:each) do
    type = DescriptorType.create! :title => "some title"
    @valid_attributes = {
      :descriptor_type_id => type.id,
      :text => "some descriptor"
    }
  end

  it "should create a new instance given valid attributes" do
    Descriptor.create!(@valid_attributes)
  end
end
