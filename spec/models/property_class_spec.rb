require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PropertyClass do

  before(:each) do
    @valid_attributes = {
      :name => "some property name",
      :multivalued => true,
      :optional => false,
      :range => "string",
    }
  end

  it "should create a new instance given valid attributes" do
    PropertyClass.create!(@valid_attributes)
  end

  it "should require a name" do
    @valid_attributes.delete :name 
    lambda { PropertyClass.create!(@valid_attributes) }.
      should raise_error( ActiveRecord::RecordInvalid )
  end

  it "should require a multivalued setting" do
    @valid_attributes.delete :multivalued
    lambda { PropertyClass.create!(@valid_attributes) }.
      should raise_error( ActiveRecord::RecordInvalid )
  end

  it "should require an optional setting" do
    @valid_attributes.delete :optional
    lambda { PropertyClass.create!(@valid_attributes) }.
      should raise_error( ActiveRecord::RecordInvalid )
  end

  it "should require a resonable range" do
    @valid_attributes[:range] = "nothing_good"
    lambda { PropertyClass.create!(@valid_attributes) }.
      should raise_error( ActiveRecord::RecordInvalid )
  end

  describe "#validate_value" do
    it "should validate a good date" do
      @valid_attributes[:range] = "date"
      property_class = PropertyClass.create!(@valid_attributes)
      property = mock "property"
      property.stub!(:value).and_return("12/25/2005")
      property_class.validate_value( property ).should be_true
    end

    it "should not validate a bad date" do
      @valid_attributes[:range] = "date"
      property_class = PropertyClass.create!(@valid_attributes)
      property = mock "property"
      property.stub!(:value).and_return("12/52/2005")
      errors = mock "errors"
      errors.should_receive(:add)
      property.should_receive(:errors).and_return(errors)
      property_class.validate_value( property ).should be_false
    end

  end

  describe "#translate_value" do

    it "should return a date for a date" do
      @valid_attributes[:range] = "date"
      property_class = PropertyClass.create!(@valid_attributes)
      property = mock "property"
      property.should_receive(:value).and_return("12/25/2005")
      property.should_receive(:date_value=).with(Date.parse("12/25/2005"))
      property_class.translate_value( property )
    end

  end

  describe "#retrieve_value" do

    it "should return a string for a string" do
      @valid_attributes[:range] = "string"
      property_class = PropertyClass.create!(@valid_attributes)
      property = mock "property"
      property.stub!(:string_value).and_return("a result")
      property.stub!(:value).and_return("a result")
      property_class.retrieve_value( property ).should == "a result"
    end

    it "should return a date for a date" do
      @valid_attributes[:range] = "date"
      property_class = PropertyClass.create!(@valid_attributes)
      property = mock "property"
      property.stub!(:date_value).and_return(Date.parse("12/25/2005"))
      property.stub!(:value).and_return("12/25/2005")
      property_class.retrieve_value( property ).should == "2005-12-25"
    end

  end

end
