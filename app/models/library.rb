class Library < ActiveRecord::Base
  validates_presence_of :title

  def self.title
    ( self.find :first ).title
  end

  def self.subtitle
    ( self.find :first ).subtitle
  end

end

