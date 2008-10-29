require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Asset do

  [ "ASSET_DIR", "SURROGATE_DIR" ].each do |dir|
    describe "::#{dir}" do
      it "should be a well formed path to an existing path" do
        File.directory?(Asset.const_get(dir)).should be_true
      end
    end
  end


  describe "validations" do

    before :each do
      @asset = Factory(:video).assets[0]
      @path = @asset.absolute_path
    end
  
    after :each do
      File.unlink @path
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
      File.stub!(:exists?).with(@asset.absolute_path).and_return(false)
      @asset.should_not be_valid
    end

  end

  describe "#before_save" do

    it "should set the size of the file when saving a new file" do

      file =
        File.open( File.join(Asset::ASSET_DIR, "look_around_you.mov"),
                   "w" ) { |f| f << "thanks ants. thants." }

      video = Video.new( :sentence => "bless you ants. blants.",
                          :title => "look around youlook around youlook"
                         )
      video.properties << Property.build( "Rights Statement", 1 )
    
      uri = "file:///look_around_you.mov"

      asset = Asset.new( :uri => uri )

      video.assets << asset    
      asset.size.should be_nil
      video.save!

      asset.size.should == File.size(file.path)
      File.delete file.path

    end
  
    it "should set the size of the file when updating a file" do
      asset = Factory(:video).assets[0]
      file = File.open(asset.absolute_path, "w") do |f|
        f << "what"*10
      end
      new_size = 40

      # Currently, size has to be nulled for this to work ... this allows
      # a size to be either given or extracted from the file but makes
      # it difficult to know, given an updated file, if the size should
      # track the file or not. Currently, the way to do this is to null
      # the size before the save.

      asset.size = nil
      
      asset.size.should_not == new_size
      asset.save
      asset.size.should == new_size

      File.unlink asset.absolute_path
    end
  end

  describe ".uncataloged_files" do

    before(:all) do
      @first = create_temp_asset("the_darjeeling_limited.avi")

      @our_mr_sun = Factory(:video).assets[0]
    
      new_dir = "a brand new directory"
      new_dir_path = File.join(Asset::ASSET_DIR, "a brand new directory")
      Dir.mkdir(new_dir_path)
      @directory = Dir.new(new_dir_path)
      @second = 
        create_temp_asset(File.join( new_dir,
                                     "the_darjeeling_limited.avi" ))
      @third = 
        create_temp_asset(File.join( new_dir,
                                     "the_limited.avi" ))
      
      @file_list = Asset.uncataloged_files
    end
  
    after(:all) do
      if @our_mr_sun
        File.unlink @our_mr_sun.absolute_path 
        @our_mr_sun.destroy
      end
      File.unlink @second.path if @second
      File.unlink @third.path if @third
      Dir.rmdir @directory.path if @directory
      File.unlink @first.path if @first
    end

    
    it "should return an array of Files" do
      @file_list.should_not be_empty
      @file_list.should be_instance_of(Array)
      @file_list.first.should be_instance_of(String)
    end
  
    it "should not include directories or cat'd files" do
      @file_list.size.should == 3
    end
  
    it "should not remove directory names" do
      @file_list.size.should == @file_list.uniq.size
    end
  
    it "should not include files that have already been cataloged" do
      @file_list.any? { |file| file == @our_mr_sun.uri }.should be_false
    end

    it "should restrict results by query pattern, if given" do
      @file_list = Asset.uncataloged_files :q => "darjee"
      @file_list.size.should == 2
    end

    it "should not match the query pattern against the absolute path" do
      @file_list = Asset.uncataloged_files :q => "spec"
      @file_list.size.should == 0
    end

    it "should match the query pattern against the directory" do
      @file_list = Asset.uncataloged_files :q => "brand new"
      @file_list.size.should == 2
    end

    it "should not match the query pattern against file:, etc." do
      @file_list = Asset.uncataloged_files :q => "file:"
      @file_list.size.should == 0
    end

    it "should limit the number of returns" do
      @file_list = Asset.uncataloged_files
      @file_list.size.should == 3
      @file_list = Asset.uncataloged_files( :limit => 1 )
      @file_list.size.should == 1
    end

    it "should page the results" do
      first = (Asset.uncataloged_files :limit => 1, :page => 0)[0]
      second = (Asset.uncataloged_files :limit => 1, :page => 1)[0]
      first.should_not == second
    end

  end

  describe "an instance" do

    before(:all) do
      @look = create_temp_asset("look_around_you.mov")
    end
  
    after(:all) do
      File.unlink @look.path
    end
  
    it "should be able to tell you the path" do
      asset = Asset.new(:uri => "file:///" + "look_around_you.mov")
      asset.absolute_path.should == \
        File.join(Asset::ASSET_DIR, "look_around_you.mov")
    end

  end

  describe "#valid_path?" do
    it "should return true if the file's path is in the assets directory" do
      asset = Asset.new(:uri => "file:///" + "a_normal_asset.mov")
      asset.should be_valid_path
    end
  
    it "should return false if the file's path is outside " +
       "the assets directory" do
      asset = Asset.new( :uri => "file:///" +
                                 File.join( "..",
                                            "..",
                                            "something_outside.mov" ))
      asset.should_not be_valid_path
    end
  end

  describe "paths" do

    it "should return a valid absolute/relative paths" do
      file = create_temp_asset("a_normal_asset.mov")
      asset = Asset.new(:uri => "file:///" + "a_normal_asset.mov")
      asset.absolute_path[0].should == ?/
      asset.relative_path[0].should_not == ?/
      File.stat(asset.absolute_path).should_not be_nil
      File.stat(File.join(Asset::ASSET_DIR,asset.relative_path)).
        should_not be_nil
      File.unlink file.path
    end

    it "should return something simple for filename "+
       "(for dsiplay and download)" do

      file = create_temp_asset("a_normal_asset.mov")
      asset = Asset.new(:uri => "file:///" + "a_normal_asset.mov")

      asset.filename.should == "a_normal_asset.mov"

      File.unlink file.path
    end
  end

  describe "#encoding" do
    it "should always be nil for now" do
      asset = Asset.new(:uri => "file:///" + "a_normal_asset.mov")
      asset.encoding.should be_nil
    end
  end

  describe "#asset_format" do
    it "should return the extension, cap'd" do
      asset = Asset.new(:uri => "file:///" + "a_normal_asset.mov")
      asset.asset_format.should == "MOV"
    end
  end

end
