class PropertyType < ActiveRecord::Base

  class NoPropertyClass < StandardError; end

  belongs_to :property_class

  validates_presence_of :name, :property_class_id

  def build_value string
    raise NoPropertyClass.new( property_class_id ) \
      unless property_class
    property_class.build_value string
  end

  def retrieve_value property
    raise NoPropertyClass.new( property_class_id ) \
      unless property_class
    property_class.retrieve_value property
  end

end
