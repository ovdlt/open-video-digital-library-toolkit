require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Property do

  before(:each) do
    @valid_attributes = {
      :video_id => 1,
      :property_type_id => 1,
      :value => "10/25/2008"
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

  it "should require a value" do
    @valid_attributes.delete :value
    lambda { Property.create!(@valid_attributes) }.
      should raise_error( ActiveRecord::RecordInvalid )
  end

  it "should require uniqueness" do
    p1 = Property.build( "Producer", "Bar" )
    p1.video_id = 1
    p2 = Property.build( "Producer", "Bar" )
    p2.video_id = 1
    p1.save.should be_true
    p2.save.should be_false
  end

  it "should have a nice interface with build" do
    video = Video.new :title => "title", :sentence => "sentence",
                       :rights_id => 1
    video.properties << Property.build( "Rights Statement", 1 )

    video.properties << Property.build( "Producer", "Bar" )

    p video.errors if !video.save
    video.save.should be_true
  end

  it "should have a nice interface with new" do
    video = Video.new :title => "title", :sentence => "sentence",
                       :rights_id => 1
    video.properties << Property.build( "Rights Statement", 1 )

    property = video.properties.build
    property.property_type = PropertyType.find_by_name "Producer"
    property.value = "Frank Capra"
    video.save.should be_true
  end

  it "should have a nice interface with new with opts" do
    video = Video.new :title => "title", :sentence => "sentence",
                       :rights_id => 1
    video.properties << Property.build( "Rights Statement", 1 )

    property = video.properties.build \
      :property_type => PropertyType.find_by_name( "Producer" ),
      :value => "Frank Capra"
    video.save.should be_true
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

    it "should build bad dates" do
      property = Property.build "Broadcast", "10/52/2005"
      property.video_id = 1
      property.save.should be_false
      property.errors.should_not be_empty
    end

  end

  describe "validations" do

    it "should not validate bad dates" do
      property = Property.build "Broadcast", "10/52/2005"
      property.video_id = 1
      property.save.should be_false
      property.errors.should_not be_empty
    end

    it "should not save bad dates" do
      property = Property.build "Broadcast", "10/52/2005"
      property.video_id = 1
      property.save.should be_false
      property.errors.should_not be_empty
    end

  end

  describe "someting" do

    it "should save dates as dates" do
      property = Property.build "Broadcast", "10/52/2005"
      property.video_id = 1
      property.save.should be_false
      property.errors.should_not be_empty
    end
    
    it "should handle dates the db doesn't handle" do
      property = Property.build "Broadcast", "10/52/2005"
      property.video_id = 1
      property.save.should be_false
      property.errors.should_not be_empty
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
      retrieved.value.should == "2005-10-25"
    end

  end

  describe ".find_by_name" do
    
    it "should raise an error if the name is invalid" do
      lambda { Property.find_by_name( "foobar" ) }.
        should raise_error( Property::PropertyTypeNotFound )
    end

    it "should select the properites" do
      p = Property.build( "Broadcast", "10/25/2001" )
      p.video_id = 1
      p.save!
      p = Property.build( "Broadcast", "10/5/2001" )
      p.video_id = 1
      p.save!
      p = Property.build( "Producer", "John Smith" )
      p.video_id = 1
      p.save!
      p = Property.build( "Producer", "John Q Public" )
      p.video_id = 1
      p.save!
      Property.find_all_by_name( "Broadcast" ).size.should == 2
    end

  end

  describe "descriptor properies" do

    it "should require descriptor values be unique" do
      p = Property.build( "Genre", "Documentary" )
      p.video_id = 1
      p.save.should be_true
      p = Property.build( "Genre", "Documentary" )
      p.video_id = 1
      p.save.should be_false
    end

    it "should accept strings" do
      p = Property.build( "Genre", "Documentary" )
      p.video_id = 1
      p.save.should be_true
      p.value.should == "Documentary"
    end

    it "should accept dvs" do
      pt = PropertyType.find_by_name "Genre"
      dv = DescriptorValue.create! :property_type => pt,
                                     :text => "myvalue"
      p = Property.new :property_type => pt,
                        :value => dv

      p.video_id = 1
      p.save.should be_true
      p.value.text.should == "myvalue"
    end

    it "should accept dvs w/o property type" do
      pt = PropertyType.find_by_name "Genre"
      dv = DescriptorValue.create! :property_type => pt,
                                     :text => "myvalue"
      p = Property.new :value => dv

      p.video_id = 1
      p.save.should be_true
      p.value.text.should == "myvalue"
    end

  end

end
