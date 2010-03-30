require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Video do

  describe "validations" do

    before :each do
      @video = Factory(:video)
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
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

  end

  describe ".recent" do
    fixtures :videos

    it "should return the most recent video (shortcut for .find ...)" do
      Video.recent(false)[0].
        should == ( Video.find :first, :order => "created_at desc" )
    end

    it "should return the n most recent videos (shortcut for .find ...)" do
      Video.recent(false,3).should ==
        ( Video.find :all, :order => "created_at desc", :limit => 3 )
    end

  end

  describe "fulltext" do

    before(:each) do
      @string = "just_for_this_test"
      @video = Factory.build :video, :sentence => @string
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should insert into FT table on save" do
      @video.id.should be_nil
      ( Video.search :search => Search.new( :text => @string ) ).should be_empty
      @video.save!
      ( Video.search :search => Search.new( :text => @string ) )[0].should == @video
    end

    it "should delete from FT table on destroy" do
      @video.save!
      ( Video.search :search => Search.new( :text => @string ) )[0].should == @video
      @video.destroy
      ( Video.search :search => Search.new( :text => @string ) ).should be_empty
    end

    it "should update FT table on update" do
      @video.save!
      ( Video.search :search => Search.new( :text => @string ) )[0].should == @video
      @new_string = "isnt_the_same"
      @video.sentence = @new_string
      @video.save!
      ( Video.search :search => Search.new( :text => @string ) ).should be_empty
      ( Video.search :search => Search.new( :text => @new_string ) )[0].should == @video
    end

    it "should normal not return a pagination object" do
      @video.save!
      ( WillPaginate::Collection ===
        ( Video.search :search => Search.new( :text => @string ) ) ).should be_false
    end

    it "should normal not return a pagination object" do
      @video.save!
      ( WillPaginate::Collection ===
        ( Video.search :search => Search.new( :text => @string ), :method => :paginate ) ).
        should be_true
    end

  end

  describe "property interface to video" do

    before(:each) do
      @video = Factory(:video)
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should allow a property to be added" do
      @video.properties << Property.build( "Producer", "Frank Capra" )
      @video.save!
    end

  end

  describe "property operations" do

    before(:each) do
      @video = Factory(:video)
      @video.properties <<
        Property.new( :property_type =>
                      PropertyType.find_by_name( "Producer" ),
                      :value => "Frank Capra" )

      @video.properties << Property.build( "Producer", "George Lucas" )
      @video.properties << Property.build( "Writer", "Stephen King" )
      @video.properties << Property.build( "Broadcast", "10/25/2005" )
      @video.properties << Property.build( "Production", "10/25/2005" )

      @video.save!

      @retrieved = Video.find @video.id

    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should find properties" do
      @retrieved.properties.find_all_by_type( "Producer" ).size.should == 2
    end

    it "should list by class" do
      @retrieved.properties.find_all_by_class( "Roles" ).size.should == 3
      @retrieved.properties.find_all_by_class( "Collections" ).size.
        should == 0
    end

    it "should search by property values"  do
      @retrieved = Video.search :search => Search.new( :text => "George Lucas" )
      @retrieved.size.should == 1
    end

    it "should require required properties" do

      pc = PropertyClass.create! :name => "myclass",
      :multivalued => false,
      :optional => false,
      :range_type => :string
      pt = PropertyType.create! :property_class_id => pc.id,
      :name =>  "mytype"

      @video.save.should be_false

    end

    it "should allow multivalued where appropriate"  do
      @video.properties << Property.build( "Producer", "Steven Spielberg" )
      @video.save.should be_true
    end

    it "should prohbit multivalued where appropriate"  do

      pc = PropertyClass.create! :name => "myclass",
      :multivalued => false,
      :optional => false,
      :range_type => :string

      pt = PropertyType.create! :property_class_id => pc.id,
      :name =>  "mytype"

      @video.save.should be_false

      @video.properties << Property.build( "mytype", "foo" )
      @video.save.should be_true

      @video.properties << Property.build( "mytype", "bar" )
      @video.save.should be_false
    end

  end

  describe "descriptor properties" do

    before(:each) do
      @video = Factory(:video)
    end

    after :each do
      begin
        File.unlink @video.assets[0].absolute_path
      rescue Errno::ENOENT; end
    end

    it "should allow a property descriptor to be added" do
      @video.properties << Property.build( "Genre", "Documentary" )
      @video.save.should be_true
    end

    it "should allow a dv shortcuts" do
      dv = DescriptorValue.find_by_text "Documentary"
      @video.properties << dv
      @video.save.should be_true
      v = Video.find @video.id
      v.properties.find_by_property_type_id(dv.property_type_id).value.text.
        should == "Documentary"
    end

    it "should not allow a property descriptor to be added multiple times" do
      @video.properties << Property.build( "Genre", "Documentary" )
      @video.properties << Property.build( "Genre", "Documentary" )
      @video.save.should be_false
    end

    it "should require mandatory descriptors" do
      pc = PropertyClass.find_by_name "Mandatory Multivalued Descriptor"
      pt = PropertyType.create! :name => "mytype",
                                 :property_class => pc
      dv = DescriptorValue.create! :property_type => pt,
                                     :text => "myvalue"
      @video.save.should be_false
      @video.properties << Property.build( "mytype", "myvalue" )
      @video.save.should be_true
    end

    it "should disallow mv descriptors when sv" do
      pc = PropertyClass.find_by_name "Mandatory Singular Descriptor"
      pt = PropertyType.create! :name => "mytype",
                                 :property_class => pc
      DescriptorValue.create! :property_type => pt, :text => "myvalue"
      DescriptorValue.create! :property_type => pt, :text => "myvaluex"
      @video.save.should be_false
      @video.properties << Property.build( "mytype", "myvalue" )
      @video.save.should be_true
      @video.properties << Property.build( "mytype", "myvaluex" )
      @video.save.should be_false
    end

    it "should allow mv descriptors when mv" do
      pc = PropertyClass.find_by_name "Optional Multivalued Descriptor"
      pt = PropertyType.create! :name => "mytype",
                                 :property_class => pc
      DescriptorValue.create! :property_type => pt, :text => "myvalue"
      DescriptorValue.create! :property_type => pt, :text => "myvaluex"
      @video.save.should be_true
      @video.properties << Property.build( "mytype", "myvalue" )
      @video.save.should be_true
      @video.properties << Property.build( "mytype", "myvaluex" )
      @video.save.should be_true
    end

    it "should find by name" do
      @video.properties << Property.build( "Genre", "Documentary" )
      @video.properties << Property.build( "Genre", "Corporate" )

      pt = PropertyType.find_by_name "Genre"

      @video.properties << Property.new( :property_type => pt,
                                          :value => "Ephemeral" )

      dv = DescriptorValue.create! :property_type => pt, :text => "myvalue"

      @video.properties << Property.new( :property_type => pt,
                                          :value => dv )

      @video.save.should be_true
      v = Video.find @video.id
      ps = v.properties.find_all_by_name "Genre"
      ps.size.should == 4
      ps.map(&:value).map(&:text).sort.should == [ "Corporate",
                                                   "Documentary",
                                                   "Ephemeral",
                                                   "myvalue" ]
    end

  end

  describe "descriptors" do

    before :each do
      @video = Factory(:video)
      @class = PropertyClass.find_by_name "Optional Multivalued Descriptor"
      @type = PropertyType.create! :name => "some descriptor",
      :property_class => @class
      @value = DescriptorValue.create! :property_type => @type,
      :text => "some descriptor"
      @property = Property.new :property_type => @type,
      :value => @value
      @p2 = Property.new :property_type => @type, :value => @value
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should start as an empty set" do
      @video.descriptors.size.should == 0
    end

    it "should allow descriptors to be added" do
      @video.descriptors.size.should == 0
      @video.properties << @property
      @video.should be_valid
      @video.save.should be_true
      @video.descriptors.size.should == 1
    end

    it "should require they be unique" do
      @video.properties << @property
      @video.properties << @p2
      @video.save.should be_false
    end

  end

  describe "descriptors/type recall and sorting" do

    before(:each) do
      @video = Factory(:video)
      @pcs = [
              PropertyClass.find_by_name( "Optional Multivalued Descriptor" ),
              PropertyClass.find_by_name( "Mandatory Multivalued Descriptor" ),
              PropertyClass.find_by_name( "Optional Singular Descriptor" ),
              PropertyClass.find_by_name( "Mandatory Singular Descriptor" ),
             ]

      @pts = [ PropertyType.create!( :name => "a",
                                     :priority => 2,
                                     :property_class => @pcs[0] ),
               PropertyType.create!( :name => "b",
                                     :priority => 1,
                                     :property_class => @pcs[1] ),
               PropertyType.create!( :name => "c",
                                     :priority => 3,
                                     :property_class => @pcs[2] ),
               PropertyType.create!( :name => "d",
                                     :priority => 4,
                                     :property_class => @pcs[3] ) ]

      @dvs = [ DescriptorValue.create!( :property_type => @pts[0],
                                        :text => "aa",
                                        :priority => 2 ),
               DescriptorValue.create!( :property_type => @pts[0],
                                        :text => "ab",
                                        :priority => 1 ),
               DescriptorValue.create!( :property_type => @pts[0],
                                        :text => "ac",
                                        :priority => 3 ),
               DescriptorValue.create!( :property_type => @pts[1],
                                        :text => "ba",
                                        :priority => 1 ),
               DescriptorValue.create!( :property_type => @pts[3],
                                        :text => "ba",
                                        :priority => 1 ) ]

      @ps = @dvs.map { |dv| Property.new :value => dv }

      @ps.each { |p| @video.properties << p }

      pp @video, @video.properties if !@video.save

      @video.save!
    end

    after :each do
      File.unlink @video.assets[0].absolute_path
    end

    it "should return all the types for a video in pri order" do
      @video.descriptor_types.should == [ @pts[1], @pts[0], @pts[3] ]
    end

    it "should return all the propertys for a video in pri order" do
      @video.properties_by_type( @pts[0] ).
        should == [ @ps[1], @ps[0], @ps[2] ]
      @video.properties_by_type( @pts[1] ).should == [ @ps[3] ]
      @video.properties_by_type( @pts[2] ).should == []
      @video.properties_by_type( @pts[3] ).should == [ @ps[4] ]
    end

  end

  describe "rights" do

    it "should find the rights type by name" do
      v = Video.find :first
      v.properties.find_by_name("Rights Statement").should_not be_nil
    end

    it "should provide a shortcut to the rights object" do
      v = Video.find :first
      v.rights.should_not be_nil
      (RightsDetail === v.rights).should be_true
    end

  end

  describe "featured" do

    it "should return the videos" do
      Video.featured.map(&:id).should == [ 1, 2, 3, 4 ]
    end

    it "should reorder the whole video" do
      Video.featured.map(&:id).should == [ 1, 2, 3, 4  ]
      Video.featured_order =  [ 4, 3, 2, 1 ]
      Video.featured.map(&:id).should == [ 4, 3, 2, 1]
    end

    it "should reorder the beginning of the video" do
      Video.featured.map(&:id).should == [ 1, 2, 3, 4  ]
      Video.featured_order = [ 2, 1 ]
      Video.featured.map(&:id).should ==  [ 2, 1, 3, 4 ]
    end

    it "should reorder the end of the video" do
      Video.featured.map(&:id).should == [1, 2, 3, 4  ]
      Video.featured_order = [ 4, 3 ]
      Video.featured.map(&:id).should == [ 1, 2, 4, 3 ]
    end

    it "should reorder the middle of the video" do
      Video.featured.map(&:id).should == [ 1, 2, 3, 4  ]
      Video.featured_order = [ 3, 2 ]
      Video.featured.map(&:id).should == [ 1, 3, 2, 4 ]
    end

    it "should reorder aribtrarilty video" do
      Video.featured.map(&:id).should == [ 1, 2, 3, 4 ]
      Video.featured_order =  [ 4, 1 ]
      Video.featured.map(&:id).should == [4, 2, 3, 1 ]
    end

  end

end
