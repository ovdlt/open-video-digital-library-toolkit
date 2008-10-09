require File.dirname(__FILE__) + '/../spec_helper'

include ApplicationHelper
include VideosHelper

describe VideosHelper do

  describe "#random" do
    
    it "should pick a random video that hasn't already been shown" do
      video1 = mock("vid 1")
      video1.stub!(:id).and_return 1
      video2 = mock("vid 2")
      video2.stub!(:id).and_return 2
      videos = [ video1, video2 ]
      descriptor = mock("descriptor")
      descriptor.stub!(:videos).and_return videos
      shown = {}
      v1 = random descriptor, shown
      shown.keys.size.should == 1
      v2 = random descriptor, shown
      v1.should_not == v2
      shown.keys.size.should == 2
      v3 = random descriptor, shown
      v3.should be_nil
      shown.keys.size.should == 2
    end

    it "should handle the case when there are no candidates" do
      videos = []
      descriptor = mock("descriptor")
      descriptor.stub!(:videos).and_return videos
      shown = { 1 => true }
      random( descriptor, shown ).should be_nil
      shown.keys.size.should == 1
    end

  end

end
