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

  it "should require non-blank text" do
    @valid_attributes[:text] =""
    DescriptorValue.new(@valid_attributes).save.should be_false
  end

  it "should require non-zero pt_ids" do
    @valid_attributes[:property_type_id] = 0
    DescriptorValue.new(@valid_attributes).save.should be_false
  end

  it "should return the property type" do
    dv = DescriptorValue.find_by_text "Documentary"
    dv.property_type.name.should == "Genre"
  end

  it "should return properties" do
    dv = DescriptorValue.find_by_text "Documentary"
    dv.properties.map(&:video_id).should == [ 1 ]
  end

  it "should return videos" do
    dv = DescriptorValue.find_by_text "Documentary"
    dv.videos(true).map(&:id).should == [ 1 ]
  end

  describe "order" do

    it "should return the collections" do
      PropertyType.find(38).values.map(&:id).should == [2, 1, 3, 4, 5]
    end

    it "should reorder the whole collection" do
      PropertyType.find(38).values.map(&:id).should == [2, 1, 3, 4, 5]
      DescriptorValue.browse_order = [1, 2, 3, 5, 4]
      PropertyType.find(38).values.map(&:id).should == [1, 2, 3, 5, 4]
    end

    it "should reorder aribtrarilty collection" do
      PropertyType.find(38).values.map(&:id).should == [2, 1, 3, 4, 5]
      DescriptorValue.browse_order = [ 4, 1 ]
      PropertyType.find(38).values.map(&:id).should == [2, 4, 3, 1, 5] 
    end

  end

end

