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
  
  it "should reject duplicate videos with the same file" do
    @video.should be_valid
    @other = Video.new @video.attributes
    @other.should_not be_valid
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
    # Currently, size has to be nulled for this to work ... room for improvment?
    video.size = nil
    video.size.should_not == new_size
    video.save
    video.size.should == new_size
  end
end

describe Video, "descriptors" do

  before :each do
    @video = Factory(:video)
    @type = DescriptorType.create! :title => "some descriptor"
    @value = Descriptor.create! :descriptor_type => @type,
                                 :text => "some descriptor"
  end

  it "should start as an empty set" do
    @video.descriptors.should == []
  end

  it "should allow descriptors to be added" do
    @video.descriptors << @value
    @video.should be_valid
    @video.save.should be_true
  end

  it "should require they be unique" do
    @video.descriptors << @value
    # the join table  so no chance for the validation to run
    lambda { @video.descriptors << @value }.should raise_error
  end

end

describe Video, ".recent" do
  fixtures :videos

  it "should return the most recent video (shortcut for .find ...)" do
    Video.recent[0].should == ( Video.find :first, :order => "created_at" )
  end

  it "should return the n most recent videos (shortcut for .find ...)" do
    Video.recent(3).should ==
      ( Video.find :all, :order => "created_at", :limit => 3 )
  end

end

describe Video do

  describe "fulltext" do

    before(:each) do
      @string = "just_for_this_test"
      @video = Factory.build :video, :sentence => @string
    end

    it "should insert into FT table on save" do
      @video.id.should be_nil
      ( Video.search :query => @string ).should be_empty
      @video.save!
      ( Video.search :query => @string )[0].should == @video
    end

    it "should delete from FT table on destroy" do
      @video.save!
      ( Video.search :query => @string )[0].should == @video
      @video.destroy
      ( Video.search :query => @string ).should be_empty
    end

    it "should update FT table on update" do
      @video.save!
      ( Video.search :query => @string )[0].should == @video
      @new_string = "isnt_the_same"
      @video.sentence = @new_string
      @video.save!
      ( Video.search :query => @string ).should be_empty
      ( Video.search :query => @new_string )[0].should == @video
    end

    it "should normal not return a pagination object" do
      @video.save!
      ( WillPaginate::Collection ===
        ( Video.search :query => @string ) ).should be_false
    end

    it "should normal not return a pagination object" do
      @video.save!
      ( WillPaginate::Collection ===
        ( Video.search :query => @string, :method => :paginate ) ).
        should be_true
    end

  end

  describe "descriptors/type recall and sorting" do

    before(:each) do
      @video = Factory(:video)
      @dts = [ DescriptorType.create!( :title => "a", :priority => 2 ),
               DescriptorType.create!( :title => "b", :priority => 1 ),
               DescriptorType.create!( :title => "c", :priority => 3 ),
               DescriptorType.create!( :title => "d", :priority => 4 ) ]
      @dss = [ Descriptor.create!( :descriptor_type => @dts[0],
                                    :text => "aa", :priority => 2 ),
               Descriptor.create!( :descriptor_type => @dts[0],
                                    :text => "ab", :priority => 1 ),
               Descriptor.create!( :descriptor_type => @dts[0],
                                    :text => "ac", :priority => 3 ),
               Descriptor.create!( :descriptor_type => @dts[1],
                                    :text => "ba", :priority => 1 ),
               Descriptor.create!( :descriptor_type => @dts[2],
                                    :text => "ba", :priority => 1 ) ]
      @video.descriptors = @dss
      @video.save!
    end

    it "should return all the types for a video in pri order" do
      @video.descriptor_types.should == [ @dts[1], @dts[0], @dts[2] ]
    end
    
    it "should return all the descriptors for a video in pri order" do
      @video.descriptors_by_type( @dts[0] ).
        should == [ @dss[1], @dss[0], @dss[2] ]
      @video.descriptors_by_type( @dts[1] ).should == [ @dss[3] ]
      @video.descriptors_by_type( @dts[2] ).should == [ @dss[4] ]
    end
    
  end

end
