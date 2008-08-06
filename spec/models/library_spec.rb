require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Library do
  before(:each) do
    @valid_attributes = {
      :title => "Library title",
      :subtitle => "about a library"
    }
  end

  it "should create a new instance given valid attributes" do
    Library.create!(@valid_attributes)
  end

  it "should reject a new instance without a title" do
    ( Library.create :subtitle => "foo" ).save.should be_false
  end

  it "should allow a new instance without a subtitle" do
    ( Library.create :title => "foo" ).save.should be_true
  end

  describe ".title" do
    it "should return the title of some library record" do
      s = "a title"
      Library.create! :title => s
      Library.title.should == s
    end
  end

  describe ".subtitle" do
    it "should return the subtitle of some library record" do
      t = "a title"
      s = "a subtitle"
      Library.create! :title => t, :subtitle => s
      Library.subtitle.should == s
    end
  end

end

