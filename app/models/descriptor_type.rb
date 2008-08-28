class DescriptorType < ActiveRecord::Base

  has_many :descriptors

  validates_presence_of :title
  validates_uniqueness_of :title

  def self.sorted min = nil
    options = { :order => "priority asc" }
    if !min.nil?
      options.merge! :conditions => [ "priority >= ?", min ]
    end
    self.find :all, options
  end

  def descriptors_sorted
    descriptors.sort { |a,b| a.priority - b.priority }
  end

end
