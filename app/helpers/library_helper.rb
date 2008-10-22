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

  def property_types_by_class pc
    @property_types.select { |pt| pt.property_class_id == pc.id }
  end

  def rights_details
    @rights_details
  end

  def descriptor_types
    pcs = PropertyClass.find( :all, :conditions => "range = 'descriptor_value'" ).map(&:id)
    @property_types.select { |pt| pcs.include?(pt.property_class_id) }
  end

  def descriptor_values pt
    @descriptor_values.select { |dv| dv.property_type_id == pt.id }
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

  end

  def dv_template property_type
    DescriptorValueTemplate.new self, property_type
  end

  class PropertyTypeTemplate
    def initialize helper, pc
      @helper = helper
      @property_class = pc
    end

    def name
      nil
    end

    def errors
      errors = []
      class << errors
        def count; length; end
      end
      errors
    end

    def property_class_id
      @property_class.id
    end

    def id
      "new_pt"
    end

  end

  def pt_template property_class
    PropertyTypeTemplate.new self, property_class
  end

  class DescriptorTypeTemplate
    def initialize helper
      @helper = helper
    end

    def name
      nil
    end

    def errors
      errors = []
      class << errors
        def count; length; end
      end
      errors
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

end
