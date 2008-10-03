require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Property do

  before(:each) do
    @valid_attributes = {
      :video_id => 1,
      :property_type_id => 1,
    }
  end

  it "should create a new instance given valid attributes" do
    Property.create!(@valid_attributes)
  end

  it "should require a video" do
    @valid_attributes.delete :video_id
    lambda { Property.create!(@valid_attributes) }.
      should raise_error( ActiveRecord::StatementInvalid )
  end

  it "should require a property type" do
    @valid_attributes.delete :property_type_id
    lambda { Property.create!(@valid_attributes) }.
      should raise_error( ActiveRecord::RecordInvalid )
  end


  describe ".build" do

    it "should error out if it can't find a type" do
      lambda { Property.build "Foo", "Bar" }.
        should raise_error( Property::PropertyTypeNotFound )
    end

    it "should build a properties and be valid appropriately" do
      property = Property.build "Producer", "Frank Capra"
      property.should_not be_nil
      property.should be_valid

      lambda { property.save }.
        should raise_error( ActiveRecord::StatementInvalid )

      property.video_id = 1
      property.save.should be_true
    end

    it "should build a string property" do
      property = Property.build "Producer", "Frank Capra"
      property.video_id = 1
      property.save.should be_true
    end

    it "should build a date property" do
      property = Property.build "Broadcast", "10/25/2005"
      property.video_id = 1
      property.save.should be_true
    end

  end

  describe "#value" do

    it "should raise an error on bogus property types" do
      property = Property.build "Broadcast", "10/25/2005"
      property.video_id = 1
      property.save.should be_true
      retrieved = Property.find property.id
      retrieved.should == property
      retrieved.property_type_id = -1
      lambda { retrieved.value }.
        should raise_error( Property::PropertyTypeNotFound )
    end

    it "should retreive a date property" do
      property = Property.build "Broadcast", "10/25/2005"
      property.video_id = 1
      property.save.should be_true
      retrieved = Property.find property.id
      retrieved.should == property
      retrieved.value.should == Date.parse( "10/25/2005" )
    end

  end


end
