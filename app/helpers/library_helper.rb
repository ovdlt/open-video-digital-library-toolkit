module LibraryHelper

  def tabs
    [
     :general_information,
     :date_types,
     :roles,
     :descriptor_types,
#     :collections,
     :digital_files,
     :rights_statements,
#     :video_relation_types,
     :format_types,
    ]
  end

  def descriptor_types
    pcs = PropertyClass.find( :all, :conditions => "range = 'descriptor_value'" ).map(&:id)
    @property_types.select { |pt| pcs.include?(pt.property_class_id) }
  end

  def default_descriptor_class
     PropertyClass.find_by_name "Optional Multivalued Descriptor"
  end

  class DescriptorValueTemplate

    attr_reader :property_type

    def initialize helper, pt
      @helper = helper
      @property_type = pt
    end

    def errors
      errors = []
      class << errors
        def count; length; end
      end
      errors
    end

    def text
      nil
    end

    def property_type_id
      @helper.type_id(@property_type)
    end

    def id
      pt_id = @helper.type_id(@property_type)
      pt_id == "new_dt" ? "template_new_dv" : "new_dv"
    end

    def browsable?
      false
    end

  end

  def dv_template property_type
    DescriptorValueTemplate.new self, property_type
  end

  class DescriptorTypeTemplate
    def initialize helper
      @helper = helper
    end

    def name
      nil
    end

    def browsable?
      false
    end

    def browsable
      false
    end

    def errors
      errors = []
      class << errors
        def count; length; end
      end
      errors
    end

    def real_object_id
      object_id
    end

    def property_class_id
      PropertyClass.find_by_name("Optional Multivalued Descriptor").id
    end

    def id
      "new_dt"
    end

  end

  def dt_template
    DescriptorTypeTemplate.new self
  end

  class RightsDetailTemplate

    def initialize helper
      @helper = helper
    end

    def errors
      errors = []
      class << errors
        def count; length; end
      end
      errors
    end

    def license
      nil
    end

    def statement
      nil
    end

    def html
      nil
    end

    def property_type_id_
      @helper.type_id(@property_type)
    end

    def id
      "new_rd"
    end

  end

  def rd_template
    RightsDetailTemplate.new self
  end

  def theme_choices
    options_for_select Library.available_themes, @library.theme
  end

  def theme_chooser
    select "library", "theme", theme_choices
  end

end
