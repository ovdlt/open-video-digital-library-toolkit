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

  def self.collections_user_id
    ( self.find :first ).collections_user_id
  end

  def self.collections_title
    ( self.find :first ).collections_title
  end

  def self.playlists_title
    ( self.find :first ).playlists_title
  end

end

