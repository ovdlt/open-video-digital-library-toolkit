require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Video, "::VIDEO_DIR" do
  it "should be a well formed path to an existing path" do
    File.directory?(Video::VIDEO_DIR).should be_true
  end
end

describe Video, "validations" do
  before :each do
    @video = Factory(:video)
  end
  
  it "should require the presence of a title" do
    @video.should be_valid
    @video.title = nil
    @video.should_not be_valid
  end
  
  it "should require the presence of a sentence" do
    @video.should be_valid
    @video.sentence = nil
    @video.should_not be_valid
  end
  
  it "should require a valid filename (i.e. a file that exists in the blessed video directory)" do
    @video.should be_valid
    @video.filename = File.join("..", "..", "look_around_you.mp4")
    @video.should_not be_valid
  end
  
  it "should require that the filename correspond to a file on disk" do
    File.stub!(:exists?).with(@video.path).and_return(false)
    @video.should_not be_valid
  end
end

describe Video, ".list_uncataloged_files" do
  before(:all) do
    create_temp_video("the_darjeeling_limited.avi")
    @our_mr_sun = Factory(:video)
    
    new_dir_path = File.join(Video::VIDEO_DIR, "a brand new directory")
    Dir.mkdir(new_dir_path)
    @directory = Dir.new(new_dir_path)
    
    @file_list = Video.list_uncataloged_files
  end
  
  after(:all) do
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

describe Video do
  before(:all) do
    create_temp_video("look_around_you.mov")
  end
  
  it "should be able to tell you the path" do
    video = Video.new(:filename => "look_around_you.mov")
    video.path.should == File.join(Video::VIDEO_DIR, "look_around_you.mov")
  end
end

describe Video, "#valid_path?" do
  it "should return true if the file's path is in the videos directory" do
    video = Video.new(:filename => "a_normal_video.mov")
    video.should be_valid_path
  end
  
  it "should return false if the file's path is outside the videos directory" do
    video = Video.new(:filename => File.join("..", "..", "something_outside.mov"))
    video.should_not be_valid_path
  end
end

describe Video, "#before_save" do
  it "should set the size of the file when saving a new file" do
    file = File.open(File.join(Video::VIDEO_DIR, "look_around_you.mov"), "w") { |f| f << "thanks ants. thants." }
    video = Video.new(:filename => "look_around_you.mov", :sentence => "bless you ants. blants.", :title => "look around youlook around youlook around you")
    
    video.size.should be_nil
    video.save
    video.size.should == File.size(file.path)
    
    File.delete file.path
  end
  
  it "should set the size of the file when updating a file" do
    video = Factory(:video)
    file = File.open(File.join(Video::VIDEO_DIR, video.filename), "w") { |f| f << "what"*10 }
    new_size = 40
    video.size.should_not == new_size
    video.save
    video.size.should == new_size
  end
end
