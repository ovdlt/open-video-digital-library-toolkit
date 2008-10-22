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
        should == descriptor_value_videos_path( 1 )
    end
    it "should redirect a query only search properly" do
      helper.sq_path( SavedQuery.new( :query_string => "foo" ) ).
        should == videos_path( :query => "foo" )
    end
    it "should redirect a combined search properly" do
      helper.sq_path( SavedQuery.new( :descriptor_value_id => 1,
                                       :query_string => "foo" ) ).
        should == descriptor_value_videos_path( 1, :query => "foo" )
    end
  end

  describe "#type_id" do

    it "should return the id of an object" do
      o = Object.new
      o.should_receive(:id).and_return(12)
      helper.type_id(o).should == "12"
    end

    it "should return the munged object id if id is nil" do
      # note we're assuming an AR object so id is sensical
      o = Object.new
      o.should_receive(:id).and_return(nil)
      helper.assigns[:rollback] = true
      helper.assigns[:new] = { :a => o }
      helper.type_id(o).should =~ /^new_\d+$/
    end

    it "should raise error if called on nil" do
      lambda { helper.type_id(nil) }.should raise_error(ArgumentError)
    end

    it "should refevert to a munged object id if the object was new and we rolled back" do
      o = Object.new
      o.stub!(:id).and_return(12)
      assigns[:rollback] = true
      assigns[:new] = { :a => o }
      helper.type_id(o).should_not == "12"
      helper.type_id(o).should =~ /^new_\d+$/
    end

  end

  describe "#error_class" do

    it "should return an error class if the object has errors" do
      o = Object.new
      o.should_receive(:errors).and_return([ 1 ])
      helper.error_class(o).should == { :class => "error" }
    end

    it "should return an empty hash otherwise" do
      o = Object.new
      o.should_receive(:errors).and_return([])
      helper.error_class(o).should == {}
    end

  end

end
