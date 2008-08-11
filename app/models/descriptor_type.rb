class DescriptorType < ActiveRecord::Base
  has_many :descriptors
  def self.each &block
    ( self.find :all ).each { |type| yield type }
  end
end
