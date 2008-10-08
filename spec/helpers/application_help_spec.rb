require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do

  describe "#file_size(file)" do
    before(:each) do
      @asset = create_temp_asset("the_doctor_dances.avi", 10.kilobytes)
    end
  
    after(:each) do
      File.unlink @asset.path
    end

    it "should return the file size in humanized bytes if it's a file" do
      helper.file_size(@asset).should == "10 KB"
    end
  
    it "should return nil if it's a directory" do
      helper.file_size(File.new(File.join(RAILS_ROOT))).should be_nil
    end

  end

  describe "#sq_path" do
    it "should redirect a blank query to the videos page" do
      helper.sq_path( SavedQuery.new ).should == videos_path
    end
    it "should redirect a descriptor only search properly" do
      helper.sq_path( SavedQuery.new( :descriptor_value_id => 1 ) ).
        should == descriptor_videos_path( 1 )
    end
    it "should redirect a query only search properly" do
      helper.sq_path( SavedQuery.new( :query_string => "foo" ) ).
        should == videos_path( :query => "foo" )
    end
    it "should redirect a combined search properly" do
      helper.sq_path( SavedQuery.new( :descriptor_value_id => 1,
                                       :query_string => "foo" ) ).
        should == descriptor_videos_path( 1, :query => "foo" )
    end
  end

end
