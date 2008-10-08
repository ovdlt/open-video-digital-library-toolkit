class DescriptorValue < ActiveRecord::Base

  belongs_to :property_type
  validates_uniqueness_of :text, :scope => :property_type_id

end
