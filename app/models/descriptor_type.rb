class DescriptorType < ActiveRecord::Base

  has_many :descriptors

  validates_presence_of :title
  validates_uniqueness_of :title

  def self.browse &block
    options = { :order => "priority asc",
                :conditions => [ "browsable = true" ] }
    ( self.find :all, options ).each &block
  end

  def descriptors_sorted
    descriptors.sort { |a,b| a.priority - b.priority }
  end

end
