class Collection < ActiveRecord::Base

  belongs_to :user
  has_many :bookmarks, :dependent => :destroy

  has_many :public_videos, :through => :bookmarks,
                           :source => :video,
                           :order => "bookmarks.created_at desc",
                           :conditions => { :public => true }

  has_many :all_videos, :through => :bookmarks,
                        :source => :video,
                        :order => "bookmarks.created_at desc"

  validates_presence_of :user_id
  validates_presence_of :title
  validate { |c|
    c.user_id and c.user_id > 0
  }

  def size public
    self.send(assoc_select(public)).count
  end
    
  def each public
    self.send(assoc_select(public)).each { |v| yield v }
  end

  def each_with_index
    self.send(assoc_select(public)).each_with_index { |v,i| yield v, i }
  end

  def poster_path public
    # this is fairly expensive (lots of little queries) but probably okay
    # for now(?) 
    if false
      videos = bookmarks.map { |bookmark| bookmark.video }
      paths = self.send(assoc_select(public)).map { |v| v.poster_path }.compact
      paths.empty? ? nil : paths[rand(paths.size)]
    else
      marks = bookmarks.find :all,
                             :include => { :video => :assets }
      paths = marks.map { |m| m.video.poster_path }.compact
      paths.empty? ? nil : paths[rand(paths.size)]
    end
  end

  def featured_on
    v = read_attribute :featured_on
    if v.blank?
      v = self.updated_at
    end
    v
  end

  private

  before_save do |collection|
    collection.send :update_featured_on
  end

  def update_featured_on
    if featured? and featured_changed?
      self.featured_on = Time::now
    end
  end

  def assoc_select public
    public ? :public_videos : :all_videos
  end

end

