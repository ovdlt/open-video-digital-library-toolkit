class RightsDetail < ActiveRecord::Base
  
  belongs_to :property_type

  validates_uniqueness_of :license
  validates_presence_of :license
  validates_presence_of :statement
  validates_presence_of :property_type_id

  def before_validation
    if attributes["property_type_id"].nil?
      self.property_type_id = PropertyType.find_by_name "Rights Statement"
    end
  end

  def before_destroy
    pt = PropertyType.find_by_name( "Rights Statement" )
    if !Property.find_by_property_type_id_and_integer_value( pt.id, id ).nil?
      errors.add "cannot destroy a rights statement if used by a video"
      false
    else
      true
    end
  end

end


