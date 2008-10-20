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

end


