class PropertyClass < ActiveRecord::Base

  has_many :property_types

  RANGE_MAP = {

    "string" => { :field => :string_value,
                  :validate  => lambda { |v| validate_string( v ) },
                  :translate => lambda { |v| translate_string(v) },
                  :retrieve  => lambda { |p| retrieve_string(p) } },

    "date" => { :field => :date_value,
                :validate  => lambda { |v| validate_date( v ) },
                :translate => lambda { |v| translate_date(v) },
                :retrieve  => lambda { |p| retrieve_date(p) } },

    "rights_detail" => { :field => :integer_value,
                :validate  => lambda { |v| validate_rights( v ) },
                :translate => lambda { |v| translate_rights(v) },
                :retrieve  => lambda { |p| retrieve_rights(p) },
                :values  => lambda { |t,o| values_rights(t,o) } },

    "descriptor_value" => { :field => :integer_value,
                :validate  => lambda { |v| validate_descriptor( v ) },
                :translate => lambda { |v| translate_descriptor(v) },
                :retrieve  => lambda { |p| retrieve_descriptor(p) },
                :priority  => lambda { |p| priority_descriptor(p) },
                :values  => lambda { |t,o| values_descriptor(t,o) } },
  }

  validates_presence_of :name
  validates_inclusion_of :multivalued, :optional, :in => [ true, false ]
  validates_inclusion_of :range_type, :in => ( RANGE_MAP.keys +
                                               RANGE_MAP.keys.map( &:to_sym ) )

  before_save { |pc|
    Symbol === pc.range_type and pc.range_type = pc.range_type.to_s
    true
  }

  class NoRangeClass < StandardError; end

  def self.simple
    find :all, :conditions => "range_type in ( 'string', 'date' )"
  end

  def tableize
    s = name
    s.titleize.delete(' ').tableize
  end

  def field
    lambdas = RANGE_MAP[range_type.to_s]
    lambdas and lambdas[:field]
  end

  def values type, options = nil
    lambdas = RANGE_MAP[range_type.to_s]
    raise NoRangeClass.new( range_type ) if not lambdas
    if lambdas[:values]
      lambdas[:values].call( type, options )
    else
      raise "not implemented"
    end
  end

  def validate_value property
    lambdas = RANGE_MAP[range_type.to_s]
    raise NoRangeClass.new( range_type ) if not lambdas
    lambdas[:validate] ? lambdas[:validate].call( property ) : true
  end

  def translate_value property
    lambdas = RANGE_MAP[range_type.to_s]
    raise NoRangeClass.new( range_type ) if not lambdas
    lambdas[:translate] ? lambdas[:translate].call( property ) : true
  end

  def retrieve_value property
    lambdas = RANGE_MAP[range_type.to_s]
    raise NoRangeClass.new( range_type ) if not lambdas
    lambdas[:retrieve].call( property )
  end

  def retrieve_priority property
    lambdas = RANGE_MAP[range_type.to_s]
    raise NoRangeClass.new( range_type ) if not lambdas
    ( l = lambdas[:priority] ) ? l.call( property ) : 0
  end

  class << self

    NIL_STRING = ""
    NIL_INTEGER = 0
    NIL_DATE = Date.new

    def fields
      [ :date_value, :string_value, :integer_value ]
    end

    def default property
      property.string_value = NIL_STRING if property.string_value.nil?
      property.date_value = NIL_DATE if property.date_value.nil?
      property.integer_value = NIL_INTEGER if property.integer_value.nil?
    end

    private

    def validate_not_blank property
      if property.value.blank?
        property.errors.add :value, "cannot be blank"
        return false
      end
      true
    end      

    def validate_string property
      validate_not_blank property
    end

    def translate_string property
      property.string_value = property.value
    end

    def retrieve_string property
      property.string_value
    end

    def validate_date property

      return false if !validate_not_blank( property )

      v = property.value

      v.gsub! /(\D)00(\D)/, '\101\2'
      v.gsub! /(\D)00$/, '\101'

      if property.value != v
        property.value = v
      end

      begin
        Date.parse( property.value )
        return true
      rescue ArgumentError => ae
        property.errors.add :value, "(#{property.value}) is an #{ae}"
        return false
      end

      # skip for now ...
      begin
        Date.parse( property.value )
        return true
      rescue ArgumentError => ae
        result = ActiveRecord::Base.connection().select_one("select date('#{property.value}')")
        if result.values.first != nil
          return true
        end
        property.errors.add :value, "(#{property.value}) is an #{ae}"
        return false
      end

    end
      
    def translate_date property
      property.date_value = Date.parse( property.value )
      return
      begin
      rescue ArgumentError => ae
        property.raw_date_value = property.value
      end

    end
      
    def retrieve_date property
      property.date_value == NIL_DATE ? nil : property.date_value.to_s
    end

    def validate_rights property
      !!( RightsDetail.find_by_id( property.value ) or
          RightsDetail.find_by_license( property.value ) )
    end

    def translate_rights property
      begin
        rd = RightsDetail.find_by_id( property.value ) ||
             RightsDetail.find_by_license( property.value )
        property.integer_value = rd.id
      rescue
      end
    end

    def retrieve_rights property
      RightsDetail.find property.integer_value
    end

    def values_rights t, options
      RightsDetail.find_all_by_property_type_id t.id, options
    end

    def validate_descriptor property
      DescriptorValue === property.value or
        !!DescriptorValue.find_by_text( property.value )
    end

    def translate_descriptor property
      begin
        dv = property.value
        DescriptorValue === dv or
          dv = DescriptorValue.find_by_text( property.value )
        dv and property.integer_value = dv.id
      rescue
      end
    end

    def retrieve_descriptor property
      DescriptorValue.find( property.integer_value )
    end

    def priority_descriptor property
      property.value.priority
    end

    def values_descriptor t, options
      DescriptorValue.find_all_by_property_type_id t.id, options
    end

  end

end
