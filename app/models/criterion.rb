class Criterion < ActiveRecord::Base

  belongs_to :search
  has_one :property

  validates_presence_of :search_id

end
