require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PropertyType do

  before(:each) do
    @valid_attributes = {
      :name => "property type name",
      :property_class_id => 1,
    }
  end

  it "should create a new instance given valid attributes" do
    PropertyType.create!(@valid_attributes)
  end

  it "should require a name" do
    @valid_attributes.delete :name 
    lambda { PropertyType.create!(@valid_attributes) }.
      should raise_error( ActiveRecord::RecordInvalid )
  end

  it "should require a class" do
    @valid_attributes.delete :property_class_id
    lambda { PropertyType.create!(@valid_attributes) }.
      should raise_error( ActiveRecord::RecordInvalid )
  end

  describe "#validate_value" do

    it "should throw a nice error if the property class is bad" do
      property_type = PropertyType.create! :name => "some name",
                                            :property_class_id => 1
      property_type.property_class_id = -1
      lambda { property_type.validate_value( "foo" ) }.
        should raise_error( PropertyType::NoPropertyClass )
    end

  end

  describe "#translate_value" do

    it "should throw a nice error if the property class is bad" do
      property_type = PropertyType.create! :name => "some name",
                                            :property_class_id => 1
      property_type.property_class_id = -1
      lambda { property_type.translate_value( "foo" ) }.
        should raise_error( PropertyType::NoPropertyClass )
    end

  end

  describe "#retrieve_value" do

    it "should throw a nice error if the property class is bad" do
      property_type = PropertyType.create! :name => "some name",
                                            :property_class_id => 1
      property_type.property_class_id = -1
      lambda { property_type.retrieve_value( "foo" ) }.
        should raise_error( PropertyType::NoPropertyClass )
    end

  end

end
