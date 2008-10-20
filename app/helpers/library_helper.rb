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


end
