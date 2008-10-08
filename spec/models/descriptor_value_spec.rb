require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DescriptorValue do

  before(:each) do
    @valid_attributes = {
      :property_type_id => 1,
      :text => "my text",
    }
  end

  it "should create a new instance given valid attributes" do
    DescriptorValue.create!(@valid_attributes)
  end

  it "should require values be unique" do
    DescriptorValue.create!(@valid_attributes)
    DescriptorValue.new(@valid_attributes).save.should be_false
  end

end

