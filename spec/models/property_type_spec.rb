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

  it "should require names be unique" do
    PropertyType.create! @valid_attributes
    PropertyType.new(@valid_attributes).save.should be_false
  end

  it "should require non-blank text" do
    @valid_attributes[:name] =""
    PropertyType.new(@valid_attributes).save.should be_false
  end

  it "should require non-zero pt_ids" do
    @valid_attributes[:property_class_id] = 0
    PropertyType.new(@valid_attributes).save.should be_false
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

  describe ".browse" do

    it "should return an ordered list of browsable properites" do
      PropertyType.browse.map(&:name).should == [ "Genre", "Language", "Geographic Region", "Color" ]
    end

    it "should yield the results, too" do
      r = []
      PropertyType.browse do |t|
        r << t.name
      end
      r.should == [ "Genre", "Language", "Geographic Region", "Color" ]

    end

  end

  describe "#values" do

    it "should return a list of descriptors for descriptor types" do
      pt = PropertyType.find_by_name "Genre"
      pt.values.map(&:text).
        should ==  [ "Corporate", "Documentary",
                     "Historical",  "Ephemeral", "Lecture" ]
    end

    it "should obey offset and limit" do
      pt = PropertyType.find_by_name "Genre"
      pt.values( :offset => 1, :limit => 2 ).map(&:text).
        should ==  [ "Documentary", "Historical" ]
    end

    it "should obey order" do
      pt = PropertyType.find_by_name "Genre"
      pt.values( :order => "priority asc" ).map(&:text).
        should ==  [ "Corporate", "Documentary", "Historical",
                     "Ephemeral", "Lecture" ].reverse
    end

  end

  describe "#properties" do

    it "should return the props for a type" do
      pt = PropertyType.find_by_name "Genre"
      pt.properties.map(&:video_id).should == [1,2]
    end
    
  end

  describe ".descriptor_types" do
    it "should return the property types that are descriptor types" do
      PropertyType.descriptor_types.map(&:name).
        should == [ "Genre", "Language", "Geographic Region", "Color", "Sound" ]
    end
  end

  describe "#descriptor_values" do

    it "should raise an error on the wrong kind of PT" do
      pt = PropertyType.find_by_name "Rights Statement"
      lambda { pt.descriptor_values }.
        should raise_error( PropertyType::NotDescriptorType )
    end

    it "should return the descriptor_values for a property" do
      pt = PropertyType.find_by_name "Genre"
      pt.descriptor_values.map(&:text).
        should == [ "Corporate", "Documentary",
                    "Historical",  "Ephemeral", "Lecture" ]
    end

  end

  describe "#values" do

    it "should return the values for rights" do
      pt = PropertyType.find_by_name "Rights Statement"
      vs = pt.values.map(&:license)
      vs.first.should == 'All Rights Reserved'
      vs.last.should == \
        'Creative Commons Attribution-NonCommercial-NoDerivs 2.5 License'
    end

  end

  describe "order" do

    it "should return the collections" do
      PropertyType.browse.map(&:id).should == [ 38, 39, 42, 40 ]
    end

    it "should reorder the whole collection" do
      PropertyType.browse.map(&:id).should == [ 38, 39, 42, 40 ]
      PropertyType.browse_order = [ 39, 42, 40, 38 ] 
      PropertyType.browse.map(&:id).should == [ 39, 42, 40, 38 ] 
    end

    it "should reorder the beginning of the collection" do
      PropertyType.browse.map(&:id).should == [ 38, 39, 42, 40 ]
      PropertyType.browse_order = [ 39, 38 ]
      PropertyType.browse.map(&:id).should ==  [ 39, 38, 42, 40 ]
    end

    it "should reorder the end of the collection" do
      PropertyType.browse.map(&:id).should == [ 38, 39, 42, 40 ]
      PropertyType.browse_order = [ 40, 42 ]
      PropertyType.browse.map(&:id).should == [ 38, 39, 40, 42 ]
    end

    it "should reorder the middle of the collection" do
      PropertyType.browse.map(&:id).should == [ 38, 39, 42, 40 ]
      PropertyType.browse_order = [ 42, 39 ]
      PropertyType.browse.map(&:id).should == [ 38, 42, 39, 40 ]
    end

    it "should reorder aribtrarilty collection" do
      PropertyType.browse.map(&:id).should == [ 38, 39, 42, 40 ]
      PropertyType.browse_order =  [ 40, 38 ]
      PropertyType.browse.map(&:id).should == [ 40, 39, 42, 38 ]
    end

  end



end

