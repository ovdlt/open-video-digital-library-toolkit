require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DescriptorType do
  before(:each) do
    @valid_attributes = {
      :title => "some descriptor"
    }
  end

  it "should create a new instance given valid attributes" do
    DescriptorType.create!(@valid_attributes)
  end

  it "should fail if not given a title" do
    d = DescriptorType.create
    d.should_not be_valid
    d.save.should be_false
    d.title = "some title"
    d.should be_valid
    d.save.should be_true
  end

  it "should require titles to be unique" do
    d = DescriptorType.create
    d.title = "some title"
    d.should be_valid
    d.save.should be_true
    d.save!
    
    d = DescriptorType.create
    d.title = "some title"
    d.should_not be_valid
    d.save.should_not be_true
    d.title = "some other title"
    d.should be_valid
    d.save.should be_true
    d.save!
  end

  describe ".each" do
    it "should return all the descriptor types (shortcut for find all)" do
      descriptors = []
      DescriptorType.each { |d| descriptors << d }
      ( descriptors.sort { |a,b| a.id - b.id } ).
        should == (( DescriptorType.find :all ).sort { |a,b| a.id - b.id })
    end
  end

end
