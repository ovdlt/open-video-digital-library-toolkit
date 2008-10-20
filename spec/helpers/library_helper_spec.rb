require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LibraryHelper do
  
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(LibraryHelper)
  end

  describe "#property_types_by_class" do
    
    it "should filter the property types variable by class" do
      assigns[:property_types] = @property_types = PropertyType.find(:all)
      @property_types << ( pt = PropertyType.new :property_class_id => 1 )

      helper.property_types_by_class( PropertyClass.find(1) ).should ==
        ( PropertyType.find_all_by_property_class_id(1) + [ pt ] )
    end

  end

  describe "#rights_details" do
    
    it "should return all the current rights details" do
      assigns[:rights_details] = @rights_details = RightsDetail.find(:all)

      @rights_details << ( rd = RightsDetail.new )

      helper.rights_details.should == ( RightsDetail.find(:all).to_a + [ rd ]  )

    end

  end

end
