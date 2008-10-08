require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RightsDetail do
  before(:each) do
    @valid_attributes = {
      :statement => "some rights statement",
      :license => "a way of labeling it",
    }

  end

  def create_rd
    rd = RightsDetail.new @valid_attributes
    pt = PropertyType.find_by_name( "Rights Statement" )
    rd.property = Property.new :property_type_id => pt.id,
                                :video_id => 1
    rd.save
  end

  it "should create a new instance given valid attributes" do
    create_rd.should be_true
  end

  it "should require license" do
    @valid_attributes.delete :license
    create_rd.should be_false
  end

  it "should require statement" do
    @valid_attributes.delete :statement
    create_rd.should be_false
  end

end
