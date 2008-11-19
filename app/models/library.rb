class Library < ActiveRecord::Base

  validates_presence_of :title
  validates_presence_of :my

  def validate
    if !User.find_by_login self.collections_login
      errors.add :collections_login, "login does not exist"
    end
  end

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
    User.find_by_login( self.find(:first).collections_login ).id
  end

  def self.collections_login
    ( self.find :first ).collections_login
  end

  def self.collections_title
    ( self.find :first ).collections_title
  end

  def self.playlists_title
    ( self.find :first ).playlists_title
  end

  def video_count public
    if public
      Video.count :conditions => { :public => true }
    else
      Video.count
    end
  end

  def available_themes
    dir = Dir.new( File.join(RAILS_ROOT,'public','themes') )
    themes = []
    dir.each do |entry|
      next if entry.match( /^\./ )
      name = File.join( dir.path, entry )
      next if !File.directory?( name )
      themes << entry
    end      
    themes
  end

end





