class DescriptorType < ActiveRecord::Base

  has_many :descriptors

  validates_presence_of :title
  validates_uniqueness_of :title

  def self.browse &block
    options = { :order => "priority asc",
                :conditions => [ "browsable = true" ] }
    ( self.find :all, options ).each &block
  end

  def self.sorted
    options = { :order => "priority asc" }
    self.find :all, options
  end

  def descriptors_prioritized
    descriptors.sort { |a,b| a.priority <=> b.priority }
  end

  def descriptors_alphabetized
    descriptors.sort { |a,b| a.text <=> b.text }
  end

end
