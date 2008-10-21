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

end
