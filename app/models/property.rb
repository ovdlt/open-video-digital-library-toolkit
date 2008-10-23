class Property < ActiveRecord::Base

  class PropertyTypeNotFound < StandardError; end

  # validation order issue; caught by msyql
  # validates_presence_of :video_id

  validates_presence_of :property_type_id

  belongs_to :video
  belongs_to :property_type

  # optionally
  # has_one :descriptor_value

  def validate

    if property_type_id.blank?
      errors.add :property_type_id, "may not be blank"
      return false
    end

    raise PropertyTypeNotFound.new( property_type_id ) unless property_type
    property_type.validate_value self

  end

  PropertyClass.fields.each do |field|
    validates_uniqueness_of field,
                            :scope => [ :video_id, :property_type_id ],
                            :if => lambda { |p| p.send :validate?, field }
  end

  def initialize options = nil
    if DescriptorValue === options
      options = { :value => options }
    end
    super
    if value = options[:value] || options["value"]
      @value = value
      if ActiveRecord::Base === value and self.property_type_id.nil?
        self.property_type_id = value.property_type_id
      end
    end
    PropertyClass.default( self )
  end
  
  def before_validation
    if property_type
      begin
        property_type.translate_value self
      rescue
      end
    end
  end

  def self.build name, value
    property_type = PropertyType.find_by_name name
    raise PropertyTypeNotFound.new( name ) unless property_type
    self.new :property_type_id => property_type.id,
             :value => value
  end

  def self.find_by_name name
    property_type = PropertyType.find_by_name name
    raise PropertyTypeNotFound.new( name ) unless property_type
    self.find_by_property_type_id property_type.id
  end

  def self.find_all_by_name name
    property_type = PropertyType.find_by_name name
    raise PropertyTypeNotFound.new( name ) unless property_type
    self.find_all_by_property_type_id property_type.id
  end

  def value= v
    @value = v
  end

  def value
    return @value if @value
    raise PropertyTypeNotFound.new( property_type_id ) unless property_type
    @value = property_type.retrieve_value self
  end

  def name
    raise PropertyTypeNotFound.new( property_type_id ) unless property_type
    property_type.name
  end

  def priority
    raise PropertyTypeNotFound.new( property_type_id ) unless property_type
    property_type.retrieve_priority self
  end

  private

  def validate? field
    property_type and property_type.field == field
  end

end
