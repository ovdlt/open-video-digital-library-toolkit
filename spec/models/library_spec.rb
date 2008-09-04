require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Library do
  before(:each) do

    ( Library.find :all ).each { |library| library.destroy }

    @valid_attributes = {
      :title => "Library title",
      :subtitle => "about a library",
      :my => "My Library",
    }

  end

  it "should create a new instance given valid attributes" do
    Library.create!(@valid_attributes)
  end

  it "should reject a new instance without a my string" do
    @valid_attributes.delete :my
    ( Library.create @valid_attributes ).save.should be_false
  end

  it "should reject a new instance without a title" do
    @valid_attributes.delete :title
    ( Library.create @valid_attributes ).save.should be_false
  end

  it "should allow a new instance without a subtitle" do
    @valid_attributes.delete :subtitle
    ( Library.create @valid_attributes ).save.should be_true
  end

  describe ".title" do
    it "should return the title of some library record" do
      s = "a title"
      my = "my title"
      Library.create! :title => s, :my => my
      Library.title.should == s
    end
  end

  describe ".subtitle" do
    it "should return the subtitle of some library record" do
      t = "a title"
      s = "a subtitle"
      my = "my title"
      Library.create! :title => t, :subtitle => s, :my => my
      Library.subtitle.should == s
    end
  end

  describe ".logo_url" do
    it "should return the logo_url of some library record" do
      t = "a title"
      s = "a logo_url"
      my = "my title"
      Library.create! :title => t, :logo_url => s, :my => my
      Library.logo_url.should == s
    end
  end

end

