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

  describe "#build_value" do

    it "should raise an error on an unspported value" do
      property_class = PropertyClass.create!(@valid_attributes)
      property_class.range = "strange"
      lambda { property_class.build_value( "foobar" ) }.
        should raise_error( PropertyClass::NoRangeClass )
    end

    it "should map a string to string value" do
      @valid_attributes[:range] = "string"
      property_class = PropertyClass.create!(@valid_attributes)
      property_class.build_value( "foobar" ).
        should == { :string_value => "foobar" }
    end

    it "should map a date to a date value" do
      @valid_attributes[:range] = "date"
      property_class = PropertyClass.create!(@valid_attributes)
      property_class.build_value( "10/25/2005" ).
        should == { :date_value => Date.parse( "10/25/2005" ) }
    end

    # Note: these checks don't handle changes that might occur by
    # roundtriping through the database

    it "should return a string for a string" do
      @valid_attributes[:range] = "string"
      property_class = PropertyClass.create!(@valid_attributes)
      property = mock "property"
      property.should_receive(:string_value).and_return("a result")
      property_class.retrieve_value( property ).should == "a result"
    end

    it "should return a date for a date" do
      @valid_attributes[:range] = "date"
      property_class = PropertyClass.create!(@valid_attributes)
      property = mock "property"
      property.should_receive(:date_value).
        and_return(Date.parse("12/25/2005"))
      property_class.retrieve_value( property ).
        should == Date.parse("12/25/2005")
    end

  end


end
