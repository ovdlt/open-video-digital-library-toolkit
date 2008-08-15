class DescriptorType < ActiveRecord::Base

  has_many :descriptors

  validates_presence_of :title
  validates_uniqueness_of :title

  def self.each &block
    ( self.find :all, :order => "priority asc" ).each { |type| yield type }
  end

  def descriptors_sorted
    descriptors.sort { |a,b| a.priority - b.priority }
  end

end
