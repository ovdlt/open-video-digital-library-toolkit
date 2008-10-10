class RightsDetail < ActiveRecord::Base
  
  belongs_to :property_type

  validates_presence_of :license
  validates_presence_of :statement

end
