require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Descriptor do

  before(:each) do
    @type = DescriptorType.create! :title => "some title"
    @valid_attributes = {
      :descriptor_type_id => @type.id,
      :text => "some descriptor"
    }
  end

  it "should create a new instance given valid attributes" do
    Descriptor.create!(@valid_attributes)
  end

  it "should require a descriptor type" do
    d = Descriptor.create
    d.text = "some text"
    # d.valid?.should be_false
    # d.save.should be_false
    lambda { d.save! }.should raise_error( ActiveRecord::StatementInvalid )
    d.descriptor_type = @type
    d.valid?.should be_true
    d.save.should be_true
  end

  it "should require some text" do
    d = Descriptor.create
    d.descriptor_type = @type
    d.valid?.should be_false
    d.save.should be_false
    d.text = "some text"
    d.valid?.should be_true
    d.save.should be_true
  end


  describe "#most_recent" do

    fixtures :videos, :descriptors, :descriptor_types, :libraries
    fixtures :descriptors_videos

    it "should return the most recent video for a descriptor" do

      descriptor = Descriptor.find 1

      descriptor.should_not be_nil
      
      videos = Video.find :all,
                           :order =>  "created_at",
                           :joins => "join descriptors_videos dv " +
                                     "on dv.video_id = videos.id",
                           :conditions => [ "dv.descriptor_id = ?",
                                            descriptor.id ]

      found = descriptor.most_recent

      found.should == videos[0]

    end

  end

end
