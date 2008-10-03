class Property < ActiveRecord::Base

  class PropertyTypeNotFound < StandardError; end

  # validation order issue; caught by msyql
  # validates_presence_of :video_id

  validates_presence_of :property_type_id

  belongs_to :video
  belongs_to :property_type

  def self.build name, value
    property_type = PropertyType.find_by_name name
    raise PropertyTypeNotFound.new( name ) unless property_type
    options = property_type.build_value value
    options[:property_type_id] = property_type.id
    self.new options
  end

  def value
    raise PropertyTypeNotFound.new( property_type_id ) unless property_type
    property_type.retrieve_value self
  end

  def self.find_by_name name
    property_type = PropertyType.find_by_name name
    raise PropertyTypeNotFound.new( name ) unless property_type
    self.find_by_property_type_id property_type.id
  end

end
