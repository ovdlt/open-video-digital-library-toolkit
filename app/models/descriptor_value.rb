class DescriptorValue < ActiveRecord::Base

  validates_uniqueness_of :text, :scope => :property_type_id

  belongs_to :property_type

  has_many :properties,
           :through => :property_type,
           :foreign_key => :id

  has_many :videos, :through => :properties

end
