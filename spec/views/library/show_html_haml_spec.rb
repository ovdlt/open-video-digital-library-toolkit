require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "library/show.html.haml" do

  before(:each) do
    assigns[:library] = @library = Library.find(:first)
    assigns[:property_types] = @property_types = PropertyType.find(:all)
    assigns[:property_classes] = @property_classes = PropertyClass.find(:all)
    assigns[:descriptor_values] =
      @descriptor_values = DescriptorValue.find(:all)
    assigns[:rights_details] = @rights_details = RightsDetail.find(:all)
    render "library/show"
  end

  it "should contain all the library attributes" do
    attributes = @library.attributes
    reject = { "updated_at" => true, "created_at" => true, "id" => true,
      "contact" => true, "about" => true, "news" => true, "privacy" => true,
      "user_tagging_enabled" => true,
      "theme" => true,
    }
    attributes.reject! { |k,v| reject[k] }
    attributes.each do |k,v|
      response.should have_tag( %(input[name='library[#{k}]'][value='#{h v}']) )
    end
  end

  it "should contain all the descriptor types and values" do

    PropertyType.descriptor_types.each do |dt|

      response.should \
        have_tag( %(input[name='property_type[#{dt.id}][name]']) +
                  %([value='#{dt.name}']) )

      dt.values.each do |dv|

        response.should \
          have_tag( %(input[name='descriptor_value[#{dv.id}][text]']) +
                    %([value='#{dv.text}']) )


        response.should \
          have_tag(
            %(input[name='descriptor_value[#{dv.id}][property_type_id]']) +
            %([value='#{dv.property_type_id}']) )



      end

    end

  end

  it "should contain all the normal property classes with their contents" do

    PropertyClass.simple.each do |pc|

      response.should have_tag( "##{pc.tableize}" ) do

        pc.property_types.each do |pt|

          response.should have_tag(
                %(input[name='property_type[#{pt.id}][name]']) +
                %([value='#{pt.name}']) )

          response.should have_tag(
                %(input[name='property_type[#{pt.id}][property_class_id]']) +
                %([value='#{pt.property_class_id}']) )

        end
          
      end
      
    end

  end

  it "should contain the rights info" do

    response.should have_tag( "#rights_statements" )

    pc = PropertyClass.find_by_name("Rights Statements")
    pt = PropertyType.find_by_property_class_id( pc.id )
    
    pc.values(pt).each do |rd|
        response.should have_tag(
                %(input[name='rights_detail[#{rd.id}][license]']) +
                %([value='#{rd.license}']) )
      end

  end

end
