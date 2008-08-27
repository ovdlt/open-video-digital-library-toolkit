require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Asset, "::ASSET_DIR" do
  it "should be a well formed path to an existing path" do
    File.directory?(Asset::ASSET_DIR).should be_true
  end
end

describe Asset, "validations" do

  before :each do
    @asset = Factory(:video).assets[0]
  end
  
  it "should reject duplicate assets with the same file" do
    @asset.should be_valid
    @other = Asset.new @asset.attributes
    @other.should_not be_valid
  end
  
  it "should require a valid filename "+
     "(i.e. a file that exists in the blessed asset directory)" do
    @asset.should be_valid
    @asset.uri = "file:///" + File.join("..", "..", "look_around_you.mp4")
    @asset.should_not be_valid
  end
  
  it "should require that the filename correspond to a file on disk" do
    File.stub!(:exists?).with(@asset.path).and_return(false)
    @asset.should_not be_valid
  end

end

describe Asset, ".list_uncataloged_files" do
  before(:all) do
    create_temp_asset("the_darjeeling_limited.avi")
    @our_mr_sun = Factory(:video).assets[0]
    
    new_dir_path = File.join(Asset::ASSET_DIR, "a brand new directory")
    Dir.mkdir(new_dir_path)
    @directory = Dir.new(new_dir_path)
    
    @file_list = Asset.list_uncataloged_files( {} )
  end
  
  after(:all) do
    @our_mr_sun.destroy
    Dir.rmdir @directory.path
  end
  
  it "should return an array of Files" do
    @file_list.should_not be_empty
    @file_list.should be_instance_of(Array)
    @file_list.first.should be_instance_of(File)
  end
  
  it "should put directories first" do
    @file_list.first.stat.should be_directory
    @file_list.last.stat.should_not be_directory
    @file_list.partition {|file| file.stat.directory? }.flatten.should == @file_list
  end
  
  it "should not include files that have already been cataloged" do
    @file_list.any? {|file| file.path == @our_mr_sun.path }.should be_false
  end
end

describe Asset do
  before(:all) do
    create_temp_asset("look_around_you.mov")
  end
  
  it "should be able to tell you the path" do
    asset = Asset.new(:uri => "file:///" + "look_around_you.mov")
    asset.path.should == File.join(Asset::ASSET_DIR, "look_around_you.mov")
  end
end

describe Asset, "#valid_path?" do
  it "should return true if the file's path is in the assets directory" do
    asset = Asset.new(:uri => "file:///" + "a_normal_asset.mov")
    asset.should be_valid_path
  end
  
  it "should return false if the file's path is outside the assets directory" do
    asset = Asset.new(:uri => "file:///" + File.join("..", "..", "something_outside.mov"))
    asset.should_not be_valid_path
  end
end

describe Asset, "#before_save" do
  it "should set the size of the file when saving a new file" do

    file =
      File.open( File.join(Asset::ASSET_DIR, "look_around_you.mov"),
                 "w" ) { |f| f << "thanks ants. thants." }

    video = Video.new( :sentence => "bless you ants. blants.",
                        :title => "look around youlook around youlook")
    
    asset = Asset.new( :uri => "file:///look_around_you.mov" )
    video.assets << asset    
    asset.size.should be_nil
    video.save
    asset.size.should == File.size(file.path)
    File.delete file.path
  end
  
  it "should set the size of the file when updating a file" do
    asset = Factory(:video).assets[0]
    file = File.open(asset.path, "w") do |f|
      f << "what"*10
    end
    new_size = 40
    # Currently, size has to be nulled for this to work ... room for improvment?
    asset.size = nil
    asset.size.should_not == new_size
    asset.save
    asset.size.should == new_size
  end
end
