require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ImportMap do
  before(:each) do
    @valid_attributes = {
      :name => "foobar",
      :yml => <<EOS
--- 
:a: :b
EOS
    }
  end

  it "should create a new instance given valid attributes" do
    ImportMap.create!(@valid_attributes)
  end

  it "should fail if the yaml isn't valid" do
    ImportMap.new(@valid_attributes.merge(:yml => <<EOS)).save.should be_false
a
sdf
::
!!7853743912@%@&$*(!@(
EOS
  end

end
