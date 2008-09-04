class Library < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :my

  def self.title
    ( self.find :first ).title
  end

  def self.subtitle
    ( self.find :first ).subtitle
  end

  def self.logo_url
    ( self.find :first ).logo_url
  end

  def self.my
    ( self.find :first ).my
  end

end

