class Descriptor < ActiveRecord::Base
  belongs_to :descriptor_type
  has_and_belongs_to_many :videos
end
