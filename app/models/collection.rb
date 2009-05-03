class Collection < ActiveRecord::Base

  default_scope :order => "collections.priority desc, collections.updated_at desc"

  belongs_to :user

  has_many :bookmarks, :dependent => :destroy

  has_many :public_videos, :through => :bookmarks,
                           :source => :video,
                           :order => "bookmarks.priority desc, bookmarks.created_at desc",
                           :conditions => { :public => true }

  has_many :all_videos, :through => :bookmarks,
                        :source => :video,
                        :order => "bookmarks.priority desc, bookmarks.created_at desc"

  validates_presence_of :user_id
  validates_presence_of :title
  validate { |c|
    c.user_id and c.user_id > 0
  }

  before_save do |collection|
    if collection.featured and collection.changed.include?( "featured" ) and !collection.changed.include?( "featured_priority" )
      collection.featured_priority = Collection.maximum("featured_priority") + 1;
    end
  end

  def self.featured
    find :all, :conditions => "featured = true",
               :order => "featured_priority desc"
  end

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

 def trivial_save
   saved = false
   class << self
     def record_timestamps; false; end
   end
   p "don't update"
   saved = save
   p "update"
   class << self
     remove_method :record_timestamps
   end
   saved
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

  def self.featured_order= ids
    objects = {}
    self.find( ids ).each { |object| objects[object.id] = object }
    objects = ids.map { |id| objects[id] }
    priorities = objects.map(&:featured_priority)
    priorities = priorities.sort.reverse
    objects.each { |o| o.featured_priority = priorities.shift }
    # this should be transactional, but ...
    objects.each { |o| o.save! }
  end

end


