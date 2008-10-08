class RightsDetail < ActiveRecord::Base
  
  belongs_to :property

  validates_presence_of :license
  validates_presence_of :statement

end


