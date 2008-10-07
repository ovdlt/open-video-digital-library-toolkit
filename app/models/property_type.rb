class PropertyType < ActiveRecord::Base

  class NoPropertyClass < StandardError; end

  belongs_to :property_class

  validates_presence_of :name, :property_class_id

  def field
    property_class and property_class.field
  end

  def validate_value string
    raise NoPropertyClass.new( property_class_id ) \
      unless property_class
    property_class.validate_value string
  end

  def translate_value string
    raise NoPropertyClass.new( property_class_id ) \
      unless property_class
    property_class.translate_value string
  end

  def retrieve_value property
    raise NoPropertyClass.new( property_class_id ) \
      unless property_class
    property_class.retrieve_value property
  end

end
