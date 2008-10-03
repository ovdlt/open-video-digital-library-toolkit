class PropertyClass < ActiveRecord::Base

  RANGE_MAP = {

    "string" => [ lambda { |v| { :string_value => v } },
                  lambda { |p| p.string_value } ],

    "date" => [ lambda { |v| { :date_value => Date.parse(v) } },
                lambda { |p| p.date_value } ],

  }

  validates_presence_of :name
  validates_inclusion_of :multivalued, :optional, :in => [ true, false ]
  validates_inclusion_of :range, :in => RANGE_MAP.keys

  class NoRangeClass < StandardError; end

  def build_value string
    lambdas = RANGE_MAP[range]
    raise NoRangeClass.new( range ) if not lambdas
    lambdas[0].call( string )
  end

  def retrieve_value property
    lambdas = RANGE_MAP[range]
    raise NoRangeClass.new( range ) if not lambdas
    lambdas[1].call( property )
  end

end
