require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe LibraryController do

  it "should use LibraryController" do
    controller.should be_an_instance_of(LibraryController)
  end

  describe ":show" do

    it "should require the user to be logged in" do
      get :show
      response.should redirect_to( login_path )
    end

    it "should require the user be an admin" do
      login_as_user
      get :show
      response.should be_missing
    end

    it "should render the library page with an assign" do
      login_as_admin
      get :show
      response.should be_success
      response.should render_template( "library/show" )
      (Library === assigns[:library]).should be_true
      assigns[:property_classes].should_not be_nil
      assigns[:property_types].should_not be_nil
      assigns[:descriptor_values].should_not be_nil
      assigns[:rights_details].should_not be_nil
    end

    it "should render the library page with an assign" do
      login_as_admin
      get :show
      response.should be_success
      response.should render_template( "library/show" )
      (Library === assigns[:library]).should be_true
    end

  end

  describe ":update" do

    before(:each) do
      login_as_admin
    end
 
    def post_good_update params = nil
      post :update, params
      response.should redirect_to( library_path )
    end

    def post_bad_update params = nil
      post :update, params
      response.should be_success
      response.should render_template( "library/show" )
    end

    it "should require the user to be logged in" do
      logout
      post :create
      response.should redirect_to( login_path )
    end

    it "should require the user be an admin" do
      login_as_user
      post :create
      response.should be_missing
    end

    it "should allow a post by the admin" do
      post_good_update
      (Library === assigns[:library]).should be_true
    end

    it "should not change anything if the params don't change" do
      l = Library.find :first

      params = {}
      params["library"] = l.attributes

      post_good_update params

      l.should == Library.find(:first)
    end

    it "should change the title if requested" do
      l = Library.find :first

      params = {}
      params["library"] = l.attributes
      params["library"]["title"] = "something different"
      
      post_good_update params

      l.title.should_not == Library.find(:first).title
      Library.find(:first).title.should == "something different"
    end

    it "should change the subtitle and my if requested" do
      l = Library.find :first

      params = {}
      params["library"] = l.attributes
      params["library"]["subtitle"] = "a"
      params["library"]["my"] = "b"
      
      post_good_update params

      l.title.should == Library.find(:first).title
      l.subtitle.should_not == Library.find(:first).title
      l.my.should_not == Library.find(:first).title
      Library.find(:first).subtitle.should == "a"
      Library.find(:first).my.should == "b"
    end

    it "should change the collections login if okay" do
      l = Library.find :first

      params = {}
      params["library"] = l.attributes
      params["library"]["collections_login"] = new_login =
        User.find( :first,
                   :conditions => "login <> '#{l.collections_login}'" ).login
      
      post_good_update params
      
      Library.find(:first).collections_login.should == new_login
    end

    it "should refuse to change the collections login if bad" do
      l = Library.find :first

      params = {}
      params["library"] = l.attributes
      params["library"]["collections_login"] = "xyzzy"
      
      post :update, params
      
      # ?
      response.should be_success
      response.should render_template( "library/show" )

      Library.find(:first).collections_login.should == l.collections_login

      assigns[:library].should_not be_nil
      flash.should_not be_nil
    end

    describe "property classes" do

      before(:each) do
        @params = {}
        @params["property_class"] =
          controller.send(:parameters)["property_class"]
        @pc_id = @params["property_class"].keys[4]
        @pc = @params["property_class"][@pc_id]
      end

      it "should require all the property classes be present " +
         "in order to process them" do
      
        post :update, @params

        response.should redirect_to(library_path)
      
        @params["property_class"].delete @params["property_class"].keys.first
      
        post :update, @params

        response.response_code.should == 400
      end

      it "should update pc attributes" do
        @pc["name"] = "something"

        post :update, @params
        response.should redirect_to( library_path )
      
        PropertyClass.find(@pc_id).name.should == "something"
      end

      it "should delete pc" do
        @pc["deleted"] = "deleted"

        post :update, @params
        response.should redirect_to(library_path)
      
        PropertyClass.find_by_id(@pc_id).should be_nil
      end

      it "should should validate pc range" do

        [ "rights_detail", "string" ].each do |range|

          @pc["range"] = range

          post :update, @params
          response.should redirect_to(library_path)
      
          PropertyClass.find(@pc_id).range.should == range
        end

        @pc["range"] = "xyzzy"

        post :update, @params

        assigns[:property_classes][@pc_id].errors.should_not be_nil

        PropertyClass.find(@pc_id).range.should == "string"
      end

    end

    describe "property types" do

      before(:each) do
        @params = {}
        @params["property_type"] =
          controller.send(:parameters)["property_type"]
        @pt_id = @params["property_type"].keys[4]
        @pt = @params["property_type"][@pt_id]
      end

      it "should require all the property types be present " +
         "in order to process them" do
      
        post :update, @params

        response.should redirect_to(library_path)
      
        @params["property_type"].delete @params["property_type"].keys.first
      
        post :update, @params

        response.response_code.should == 400
      end

      it "should update pt attributes" do
        @pt["name"] = "something"

        post :update, @params
        response.should redirect_to(library_path)
      
        PropertyType.find(@pt_id).name.should == "something"
      end

      it "should delete pt" do
        @pt["deleted"] = "deleted"

        post :update, @params
        response.should redirect_to(library_path)
      
        PropertyType.find_by_id(@pt_id).should be_nil
      end

      it "should be okay with 'new' ids" do
        new = @params["property_type"]["new"] = {}
        new["name"] = "foo"

        post :update, @params
        response.should redirect_to(library_path)
      end

      it "should add pts" do
        new = @params["property_type"]["new_1123"] = {}
        new["name"] = "foo"
        new["property_class_id"] = 1
        new["deleted"] = nil

        post :update, @params
        response.should redirect_to(library_path)

        PropertyType.find_by_name("foo").should_not be_nil
      end
      
      it "should not add pt with dup name" do
        new = @params["property_type"]["new_1123"] = {}
        new["name"] = "Writer"
        new["property_class_id"] = 1
        new["deleted"] = nil

        post :update, @params

        response.should be_success
        response.should render_template( "library/show" )

        assigns[:library].should_not be_nil
        flash.should_not be_nil
      end
      
      it "should not rename a pt to a dup name" do
        
        writer_key, writer_value = @params["property_type"].detect { |k,v| v["name"] == "Writer" }
        writer_value["name"] = "Producer"
        
        post :update, @params

        response.should be_success
        response.should render_template( "library/show" )

        assigns[:library].should_not be_nil
        flash.should_not be_nil
      end
      
    end

    describe "rights details" do

      before(:each) do
        RightsDetail.create! :license => "foo", :statement => "bar"

        @params = {}
        @params["rights_detail"] =
          controller.send(:parameters)["rights_detail"]

        @rd_id = @params["rights_detail"].keys[4]
        @rd = @params["rights_detail"][@rd_id]

        @new_rd = @params["rights_detail"].select do |k,v|
          v["license"] == "foo"
        end
        @new_rd_id = @new_rd[0].first
        @new_rd = @new_rd[0].last

        @pt_id = PropertyType.find_by_name("Rights Statement").id
      end

      it "should require all the rights details be present " +
         "in order to process them" do
      
        post :update, @params

        response.should redirect_to(library_path)
      
        @params["rights_detail"].delete @params["rights_detail"].keys.first
      
        post :update, @params

        response.response_code.should == 400
      end

      it "should update rd attributes" do
        @rd["license"] = "something"

        post :update, @params
        response.should redirect_to(library_path)
      
        RightsDetail.find(@rd_id).license.should == "something"
      end

      it "should not delete rd if it has videos" do
        @rd["deleted"] = "deleted"

        post :update, @params

        response.should be_success
        response.should render_template( "library/show" )

        assigns[:library].should_not be_nil
        flash.should_not be_nil

        RightsDetail.find_by_id(@rd_id).should_not be_nil
      end

      it "should delete rd if it has no videos" do
        @new_rd["deleted"] = "deleted"

        post :update, @params
        response.should redirect_to(library_path)
      
        RightsDetail.find_by_id(@new_rd_id).should be_nil
      end

      it "should be okay with 'new' ids" do
        new = @params["rights_detail"]["new"] = {}
        new["license"] = "foo"
        new["statement"] = "foo st"
        new["html"] = "foo html"

        post :update, @params
        response.should redirect_to(library_path)
      end

      it "should add rds" do
        new = @params["rights_detail"]["new_1123"] = {}
        new["license"] = "fooby"
        new["statement"] = "foo st"
        new["html"] = "foo html"
        new["deleted"] = nil
        new["property_type_id"] = @pt_id

        post :update, @params
        response.should redirect_to(library_path)

        RightsDetail.find_by_license("foo").should_not be_nil
      end
      
      it "should not add rd with dup license" do
        new = @params["rights_detail"]["new_1123"] = {}
        new["license"] = "All Rights Reserved"
        new["statement"] = "foo st"
        new["html"] = "foo html"
        new["deleted"] = nil

        post :update, @params

        response.should be_success
        response.should render_template( "library/show" )

        assigns[:library].should_not be_nil
        flash.should_not be_nil
      end
      
      it "should not rename a rd to a dup name" do
        
        arr_key, arr_value = @params["rights_detail"].
          detect { |k,v| v["license"] == "All Rights Reserved" }
        arr_value["license"] = "Creative Commons Attribution 2.5 License"
        
        post :update, @params

        response.should be_success
        response.should render_template( "library/show" )

        assigns[:library].should_not be_nil
        flash.should_not be_nil
      end
      
    end

    describe "descriptor values" do

      before(:each) do
        @params = {}
        @params["descriptor_value"] =
          controller.send(:parameters)["descriptor_value"]
        @dv_id = @params["descriptor_value"].keys[4]
        @dv = @params["descriptor_value"][@dv_id]
        @pt_id = PropertyType.find_by_name("Genre").id
      end

      it "should require all the descriptor values be present " +
         "in order to process them" do
      
        post :update, @params

        response.should redirect_to(library_path)
      
        @params["descriptor_value"].delete @params["descriptor_value"].keys.first
      
        post :update, @params

        response.response_code.should == 400
      end

      it "should update dv attributes" do
        @dv["text"] = "something"

        post :update, @params
        response.should redirect_to(library_path)
      
        DescriptorValue.find(@dv_id).text.should == "something"
      end

      it "should delete dv" do
        @dv["deleted"] = "deleted"

        post :update, @params
        response.should redirect_to(library_path)
      
        DescriptorValue.find_by_id(@dv_id).should be_nil
      end

      it "should be okay with 'new' ids" do
        new = @params["descriptor_value"]["new"] = {}
        new["text"] = "foo"
        new["statement"] = "foo st"
        new["html"] = "foo html"

        post :update, @params
        response.should redirect_to(library_path)
      end

      it "should add dvs" do
        new = @params["descriptor_value"]["new_1123"] = {}
        new["text"] = "foo"
        new["deleted"] = nil
        new["property_type_id"] = @pt_id

        post :update, @params
        response.should redirect_to(library_path)

        DescriptorValue.find_by_text("foo").should_not be_nil
      end
      
      it "should not add dv with dup text" do
        new = @params["descriptor_value"]["new_1123"] = {}
        new["text"] = "Documentary"
        new["deleted"] = nil
        new["property_type_id"] = @pt_id

        post :update, @params

        response.should be_success
        response.should render_template( "library/show" )

        assigns[:library].should_not be_nil
        flash.should_not be_nil
      end
      
      it "should not rename a dv to a dup name" do
        
        arr_key, arr_value = @params["descriptor_value"].
          detect { |k,v| v["text"] == "Italian" }
        arr_value["text"] = "Spanish"
        
        post :update, @params

        response.should be_success
        response.should render_template( "library/show" )

        assigns[:library].should_not be_nil
        flash.should_not be_nil
      end
      
    end

    describe "property types as descriptor types" do

      before(:each) do
        @params = {}
        @params["property_type"] =
          controller.send(:parameters)["property_type"]
        @dc_id = PropertyClass.find_by_name( "Optional Multivalued Descriptor" ).id
      end

      it "should be okay with 'new' ids" do
        new = @params["property_type"]["new_pt"] = {}
        new["name"] = "foo"
        post :update, @params
        response.should redirect_to(library_path)
      end

      it "should add pts" do
        new = @params["property_type"]["new_pt_1123"] = {}
        new["name"] = "foo"
        new["property_class_id"] = @dc_id
        new["deleted"] = nil

        post :update, @params
        response.should redirect_to(library_path)

        PropertyType.find_by_name("foo").should_not be_nil
      end
      
    end

    describe "new descriptor values" do

      before(:each) do
        @params = {}
        @params["property_type"] =
          controller.send(:parameters)["property_type"]
        @dc_id = PropertyClass.find_by_name( "Optional Multivalued Descriptor" ).id
      end

      it "should be okay with 'new' ids" do
        new = @params["property_type"]["new_pt"] = {}
        new["name"] = "foo"
        post :update, @params
        response.should redirect_to(library_path)
      end

      it "should add pts" do
        new = @params["property_type"]["new_pt_1123"] = {}
        new["name"] = "foo"
        new["property_class_id"] = @dc_id
        new["deleted"] = nil

        post :update, @params
        response.should redirect_to(library_path)

        PropertyType.find_by_name("foo").should_not be_nil
      end
      
    end

  end

  describe ".parameters" do

    it "should generate a complete set of parameters for the library object" do

      reference =  {
        "library" => {
          "title" => "Northeast Historic Film Archives",
          "subtitle" =>
          "a digital library for the Northeast Historic Film archives",
          "my" => "My NHF",
          "collections_title" => "NHF Special Collections",
          "playlists_title" => "NHF Public Playlists",
          "collections_login" => "collections",
          "logo_url" =>
          "http://www.oldfilm.org/themes/oldfilm/images/nhflogo.jpg",
          "org_link" =>
          '"Northeast Historic Film":http://www.oldfilm.org/',
          "copyright" =>
          "&copy; Northeast Historic Film. All Rights Reserved.",
        },

        "property_class" =>
        {
          1 => { "name" => "Date Types",
                 "multivalued" => true,
                 "optional" => true,
                 "range" => "date" },

          2 => { "name" => "Roles",
                 "multivalued" => true,
                 "optional" => true,
                 "range" => "string" },

          4 => { "name" => "Optional Multivalued Descriptor",
                 "multivalued"=>true,
                 "optional"=>true,
                 "range"=>"descriptor_value" },

          5 => { "name"=>"Digital Files",
                 "multivalued"=>true,
                 "optional"=>true,
                 "range"=>"string" },

          6 => {"name"=>"Rights Statements",
                 "multivalued"=>false,
                 "optional"=>false,
                 "range"=>"rights_detail"},

          7 => {"name"=>"Mandatory Multivalued Descriptor",
                 "multivalued"=>true,
                 "optional"=>false,
                 "range"=>"descriptor_value"},

          8 => {"name"=>"Optional Singular Descriptor",
                 "multivalued"=>false,
                 "optional"=>true,
                 "range"=>"descriptor_value"},
          
          9 => {"name"=>"Mandatory Singular Descriptor",
                 "multivalued"=>false,
                 "optional"=>false,
                 "range"=>"descriptor_value"},

          10 => {"name"=>"Format Types",
                 "multivalued"=>true,
                 "optional"=>true,
                 "range"=>"string"}
        },


        "property_type" =>
        { 1 => {"name"=>"Broadcast", "property_class_id"=>1,
            "browsable"=>false, "priority"=>999},
          2 => {"name"=>"Copyright", "property_class_id"=>1,
            "browsable"=>false, "priority"=>999},
          3 => {"name"=>"Creation", "property_class_id"=>1,
            "browsable" =>false, "priority"=>999},
          4 => {"name"=>"Digitization", "property_class_id"=>1,
            "browsable"=>false, "priority"=>999},
          5 => {"name"=>"Production", "property_class_id"=>1,
            "browsable"=>false, "priority"=>999},
          6 => {"name"=>"Rebroadcast", "property_class_id"=>1,
            "browsable"=>false, "priority"=>999},
          7 => {"name"=>"Reissue", "property_class_id"=>1,
            "browsable"=>false, "priority"=>999},
          8 => {"name"=>"Release", "property_class_id"=>1,
            "browsable"=>false, "priority"=>999},
          9 => {"name"=>"Screening", "property_class_id"=>1,
            "browsable"=>false, "priority"=>999},
          10 => {"name"=>"Commentator", "property_class_id"=>2,
            "browsable"=>false, "priority"=>999},
          11 => {"name"=>"Contributor", "property_class_id"=>2,
            "browsable"=>false, "priority"=>999},
          12 => {"name"=>"Copyright Holder", "property_class_id"=>2,
            "browsable"=>false, "priority"=>999},
          13 => {"name"=>"Director", "property_class_id"=>2,
            "browsable"=>false, "priority"=>999},
          14 => {"name"=>"Distributor", "property_class_id"=>2,
            "browsable"=>false, "priority"=>999},
          15 => {"name"=>"Performer", "property_class_id"=>2,
            "browsable"=>false, "priority"=>999},
          16 => {"name"=>"Producer", "property_class_id"=>2,
            "browsable"=>false, "priority"=>999},
          17 => {"name"=>"Writer", "property_class_id"=>2,
            "browsable"=>false, "priority"=>999},
          23 => {"name"=>"Administrative item", "property_class_id"=>5,
            "browsable"=>false, "priority"=>999},
          24 => {"name"=>"Digital video","property_class_id"=>5,
            "browsable"=>false, "priority"=>999},
          25 => {"name"=>"Production itema", "property_class_id"=>5,
            "browsable"=>false, "priority"=>999},
          26 => {"name"=>"Promotional item", "property_class_id"=>5,
            "browsable"=>false, "priority"=>999},
          27 => {"name"=>"Related document", "property_class_id"=>5,
            "browsable"=>false, "priority"=>999},
          28 => {"name"=>"GIF", "property_class_id"=>10,
            "browsable"=> false, "priority"=>999},
          29 => {"name"=>"JPG", "property_class_id"=>10,
            "browsable"=>false, "priority"=>999},
          30 => {"name"=>"MOV", "property_class_id"=>10,
            "browsable"=>false, "priority"=>999},
          31 => {"name"=>"MPEG-1", "property_class_id"=>10,
            "browsable"=>false, "priority"=>999},
          32 => {"name"=>"MPEG-2", "property_class_id"=>10,
            "browsable"=>false, "priority"=>999},
          33 => {"name"=>"MPEG-4", "property_class_id"=> 10,
            "browsable"=>false, "priority"=>999},
          34 => {"name"=>"MPEG-7", "property_class_id"=>10,
            "browsable"=>false, "priority"=>999},
          35 => {"name"=>"PDF", "property_class_id"=>10,
            "browsable"=>false, "priority"=>999},
          36 => {"name"=>"PNG", "property_class_id"=>10,
            "browsable"=>false, "priority"=>999},
          37 => {"name"=>"Rights Statement", "property_class_id"=>6,
            "browsable"=>false, "priority"=>999},
          38 => {"name"=>"Genre", "property_class_id"=>4,
            "browsable"=>true, "priority"=>1},
          39 => {"name"=>"Language", "property_class_id"=>4,
            "browsable"=>true, "priority"=>2},
          40 => {"name"=>"Color", "property_class_id"=>4,
            "browsable"=>true, "priority"=>4},
          41 => {"name"=>"Sound", "property_class_id"=>4,
            "browsable"=>false, "priority"=>5},
          42 => {"name"=>"Geographic Region", "property_class_id"=>4,
            "browsable"=>true, "priority"=>3}
        },

        "descriptor_value"=>{
          38=>{"property_type_id"=>42, "text"=>"Africa", "priority"=>999},
          5=>{"property_type_id"=>38, "text"=>"Lecture", "priority"=>999},
          11=>{"property_type_id"=>42, "text"=>"North America",
            "priority"=>999},
          39=>{"property_type_id"=>42, "text"=>"Europe", "priority"=>999},
          17=>{"property_type_id"=>40, "text"=>"Color", "priority"=>999},
          6=>{"property_type_id"=>39, "text"=>"Spanish", "priority"=>999},
          1=>{"property_type_id"=>38, "text"=>"Documentary", "priority"=>999},
          18=>{"property_type_id"=>40, "text"=>"Black and White",
            "priority"=>999},
          7=>{"property_type_id"=>39, "text"=>"French", "priority"=>999},
          2=>{"property_type_id"=>38, "text"=>"Corporate", "priority"=>999},
          19=>{"property_type_id"=>40, "text"=>"Colorized", "priority"=>999},
          8=>{"property_type_id"=>39, "text"=>"Italian", "priority"=>999},
          14=>{"property_type_id"=>42, "text"=>"Central America", "priority"=>999},
          3=>{"property_type_id"=>38, "text"=>"Historical", "priority"=>999},
          42=>{"property_type_id"=>42, "text"=>"Asia", "priority"=>999},
          20=>{"property_type_id"=>41, "text"=>"Sound", "priority"=>999},
          9=>{"property_type_id"=>39, "text"=>"English", "priority"=>999},
          15=>{"property_type_id"=>42, "text"=>"South America", "priority"=>999},
          4=>{"property_type_id"=>38, "text"=>"Ephemeral", "priority"=>999},
          21=>{"property_type_id"=>41, "text"=>"Silent", "priority"=>999},
          10=>{"property_type_id"=>39, "text"=>"Japanese", "priority"=>999}
        },

        "rights_detail"=>
        {5=>
          {"html"=>
            "<!--Creative Commons License--><a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc/2.5/\"><img alt=\"Creative Commons License\" border=\"0\" src=\"http://creativecommons.org/images/public/somerights20.png\"/></a><br/>This work is licensed under a <a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc/2.5/\">Creative Commons Attribution-NonCommercial 2.5 License</a>.<!--/Creative Commons License--><!-- <rdf:RDF xmlns=\"http://web.resource.org/cc/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"> <Work rdf:about=\"\"> <license rdf:resource=\"http://creativecommons.org/licenses/by-nc/2.5/\" /> </Work> <License rdf:about=\"http://creativecommons.org/licenses/by-nc/2.5/\"><permits rdf:resource=\"http://web.resource.org/cc/Reproduction\"/><permits rdf:resource=\"http://web.resource.org/cc/Distribution\"/><requires rdf:resource=\"http://web.resource.org/cc/Notice\"/><requires rdf:resource=\"http://web.resource.org/cc/Attribution\"/><prohibits rdf:resource=\"http://web.resource.org/cc/CommercialUse\"/><permits rdf:resource=\"http://web.resource.org/cc/DerivativeWorks\"/></License></rdf:RDF> -->",
            "property_type_id"=>37,
            "license"=>"Creative Commons Attribution-NonCommercial 2.5 License",
            "statement"=>"Rights available via Creative Commons license per donor"},
          6=>
          {"html"=>
            "<!--Creative Commons License--><a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc-sa/2.5/\"><img alt=\"Creative Commons License\" border=\"0\" src=\"http://creativecommons.org/images/public/somerights20.png\"/></a><br/>This work is licensed under a <a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc-sa/2.5/\">Creative Commons Attribution-NonCommercial-ShareAlike 2.5 License</a>.<!--/Creative Commons License--><!-- <rdf:RDF xmlns=\"http://web.resource.org/cc/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"> <Work rdf:about=\"\"> <license rdf:resource=\"http://creativecommons.org/licenses/by-nc-sa/2.5/\" /> </Work> <License rdf:about=\"http://creativecommons.org/licenses/by-nc-sa/2.5/\"><permits rdf:resource=\"http://web.resource.org/cc/Reproduction\"/><permits rdf:resource=\"http://web.resource.org/cc/Distribution\"/><requires rdf:resource=\"http://web.resource.org/cc/Notice\"/><requires rdf:resource=\"http://web.resource.org/cc/Attribution\"/><prohibits rdf:resource=\"http://web.resource.org/cc/CommercialUse\"/><permits rdf:resource=\"http://web.resource.org/cc/DerivativeWorks\"/><requires rdf:resource=\"http://web.resource.org/cc/ShareAlike\"/></License></rdf:RDF> -->",
            "property_type_id"=>37,
            "license"=>
            "Creative Commons Attribution-NonCommercial-ShareAlike 2.5 License",
            "statement"=>"Rights available via Creative Commons license per donor"},
          1=>
          {"html"=>"No reuse without permission of owner.",
            "property_type_id"=>37,
            "license"=>"All Rights Reserved",
            "statement"=>"All Rights Reserved"},
          7=>
          {"html"=>
            "<!--Creative Commons License--><a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc-nd/2.5/\"><img alt=\"Creative Commons License\" border=\"0\" src=\"http://creativecommons.org/images/public/somerights20.png\"/></a><br/>This work is licensed under a <a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nc-nd/2.5/\">Creative Commons Attribution-NonCommercial-NoDerivs 2.5 License</a>.<!--/Creative Commons License--><!-- <rdf:RDF xmlns=\"http://web.resource.org/cc/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"> <Work rdf:about=\"\"> <license rdf:resource=\"http://creativecommons.org/licenses/by-nc-nd/2.5/\" /> </Work> <License rdf:about=\"http://creativecommons.org/licenses/by-nc-nd/2.5/\"><permits rdf:resource=\"http://web.resource.org/cc/Reproduction\"/><permits rdf:resource=\"http://web.resource.org/cc/Distribution\"/><requires rdf:resource=\"http://web.resource.org/cc/Notice\"/><requires rdf:resource=\"http://web.resource.org/cc/Attribution\"/><prohibits rdf:resource=\"http://web.resource.org/cc/CommercialUse\"/></License></rdf:RDF> -->",
            "property_type_id"=>37,
            "license"=>
            "Creative Commons Attribution-NonCommercial-NoDerivs 2.5 License",
            "statement"=>"Rights available via Creative Commons license per donor"},
          2=>
          {"html"=>
            "<!--Creative Commons License--><a rel=\"license\" href=\"http://creativecommons.org/licenses/by/2.5/\"><img alt=\"Creative Commons License\" border=\"0\" src=\"http://creativecommons.org/images/public/somerights20.png\"/></a><br/>This work is licensed under a <a rel=\"license\" href=\"http://creativecommons.org/licenses/by/2.5/\">Creative Commons Attribution 2.5 License</a>.<!--/Creative Commons License--><!-- <rdf:RDF xmlns=\"http://web.resource.org/cc/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"> <Work rdf:about=\"\"> <license rdf:resource=\"http://creativecommons.org/licenses/by/2.5/\" /> </Work> <License rdf:about=\"http://creativecommons.org/licenses/by/2.5/\"><permits rdf:resource=\"http://web.resource.org/cc/Reproduction\"/><permits rdf:resource=\"http://web.resource.org/cc/Distribution\"/><requires rdf:resource=\"http://web.resource.org/cc/Notice\"/><requires rdf:resource=\"http://web.resource.org/cc/Attribution\"/><permits rdf:resource=\"http://web.resource.org/cc/DerivativeWorks\"/></License></rdf:RDF> -->",
            "property_type_id"=>37,
            "license"=>"Creative Commons Attribution 2.5 License",
            "statement"=>"Rights available via Creative Commons license per donor"},
          3=>
          {"html"=>
            "<!--Creative Commons License--><a rel=\"license\" href=\"http://creativecommons.org/licenses/by-sa/2.5/\"><img alt=\"Creative Commons License\" border=\"0\" src=\"http://creativecommons.org/images/public/somerights20.png\"/></a><br/>This work is licensed under a <a rel=\"license\" href=\"http://creativecommons.org/licenses/by-sa/2.5/\">Creative Commons Attribution-ShareAlike 2.5 License</a>.<!--/Creative Commons License--><!-- <rdf:RDF xmlns=\"http://web.resource.org/cc/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"> <Work rdf:about=\"\"> <license rdf:resource=\"http://creativecommons.org/licenses/by-sa/2.5/\" /> </Work> <License rdf:about=\"http://creativecommons.org/licenses/by-sa/2.5/\"><permits rdf:resource=\"http://web.resource.org/cc/Reproduction\"/><permits rdf:resource=\"http://web.resource.org/cc/Distribution\"/><requires rdf:resource=\"http://web.resource.org/cc/Notice\"/><requires rdf:resource=\"http://web.resource.org/cc/Attribution\"/><permits rdf:resource=\"http://web.resource.org/cc/DerivativeWorks\"/><requires rdf:resource=\"http://web.resource.org/cc/ShareAlike\"/></License></rdf:RDF> -->",
            "property_type_id"=>37,
            "license"=>"Creative Commons Attribution-ShareAlike 2.5 License",
            "statement"=>"Rights available via Creative Commons license per donor"},
          4=>
          {"html"=>
            "<!--Creative Commons License--><a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nd/2.5/\"><img alt=\"Creative Commons License\" border=\"0\" src=\"http://creativecommons.org/images/public/somerights20.png\"/></a><br/>This work is licensed under a <a rel=\"license\" href=\"http://creativecommons.org/licenses/by-nd/2.5/\">Creative Commons Attribution-NoDerivs 2.5 License</a>.<!--/Creative Commons License--><!-- <rdf:RDF xmlns=\"http://web.resource.org/cc/\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"> <Work rdf:about=\"\"> <license rdf:resource=\"http://creativecommons.org/licenses/by-nd/2.5/\" /> </Work> <License rdf:about=\"http://creativecommons.org/licenses/by-nd/2.5/\"><permits rdf:resource=\"http://web.resource.org/cc/Reproduction\"/><permits rdf:resource=\"http://web.resource.org/cc/Distribution\"/><requires rdf:resource=\"http://web.resource.org/cc/Notice\"/><requires rdf:resource=\"http://web.resource.org/cc/Attribution\"/></License></rdf:RDF> -->",
            "property_type_id"=>37,
            "license"=>"Creative Commons Attribution-NoDerivs 2.5 License",
            "statement"=>"Rights available via Creative Commons license per donor"}
        }


      }
      
      pp controller.send(:parameters), reference \
        if controller.send(:parameters) != reference

      controller.send(:parameters).should == reference

    end

  end

end
