require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RightsDetail do
  before(:each) do

    p = Property.new :property_type_id =>
                      PropertyType.find_by_name( "Rights Statement" ).id

    @valid_attributes = {
      :statement => "some rights statement",
      :license => "a way of labeling it",
      :property_id => p.id
    }

  end

  it "should create a new instance given valid attributes" do
    pending
    RightsDetail.create!(@valid_attributes)
  end
end
