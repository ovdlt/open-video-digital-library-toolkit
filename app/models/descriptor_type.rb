class DescriptorType < ActiveRecord::Base

  has_many :descriptors

  validates_presence_of :title
  validates_uniqueness_of :title

  def self.each &block
    ( self.find :all ).each { |type| yield type }
  end

end
