class PropertyClass < ActiveRecord::Base

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
                :retrieve  => lambda { |p| retrieve_rights(p) } },

    "descriptor_value" => { :field => :integer_value,
                :validate  => lambda { |v| validate_descriptor( v ) },
                :translate => lambda { |v| translate_descriptor(v) },
                :retrieve  => lambda { |p| retrieve_descriptor(p) },
                :priority  => lambda { |p| priority_descriptor(p) },
                :values  => lambda { |t,o| values_descriptor(t,o) } },
  }

  validates_presence_of :name
  validates_inclusion_of :multivalued, :optional, :in => [ true, false ]
  validates_inclusion_of :range, :in => ( RANGE_MAP.keys +
                                          RANGE_MAP.keys.map( &:to_sym ) )

  before_save { |pc|
    Symbol === pc.range and pc.range = pc.range.to_s
    true
  }

  class NoRangeClass < StandardError; end

  def field
    lambdas = RANGE_MAP[range.to_s]
    lambdas and lambdas[:field]
  end

  def values type, options
    lambdas = RANGE_MAP[range.to_s]
    raise NoRangeClass.new( range ) if not lambdas
    if lambdas[:values]
      lambdas[:values].call( type, options )
    else
      raise "not implemented"
    end
  end

  def validate_value property
    lambdas = RANGE_MAP[range.to_s]
    raise NoRangeClass.new( range ) if not lambdas
    lambdas[:validate] ? lambdas[:validate].call( property ) : true
  end

  def translate_value property
    lambdas = RANGE_MAP[range.to_s]
    raise NoRangeClass.new( range ) if not lambdas
    lambdas[:translate] ? lambdas[:translate].call( property ) : true
  end

  def retrieve_value property
    lambdas = RANGE_MAP[range.to_s]
    raise NoRangeClass.new( range ) if not lambdas
    lambdas[:retrieve].call( property )
  end

  def retrieve_priority property
    lambdas = RANGE_MAP[range.to_s]
    raise NoRangeClass.new( range ) if not lambdas
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

      begin
        Date.parse( property.value )
        return true
      rescue ArgumentError => ae
        property.errors.add :value, ae.to_s
        return false
      end

    end
      
    def translate_date property
      property.date_value = Date.parse( property.value )
    end
      
    def retrieve_date property
      property.date_value == NIL_DATE ? nil : property.date_value.to_s
    end

    def validate_rights property
      !!RightsDetail.find_by_id( property.value )
    end

    def translate_rights property
      begin
        property.integer_value = property.value.to_i
      rescue
      end
    end

    def retrieve_rights property
      property.integer_value
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
