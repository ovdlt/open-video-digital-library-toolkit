class Collection < ActiveRecord::Base

  belongs_to :user
  has_many :bookmarks, :dependent => :destroy
  has_many :videos, :through => :bookmarks,
                    :order => "bookmarks.created_at desc"

  validates_presence_of :user_id
  validates_presence_of :title
  validate { |c|
    c.user_id and c.user_id > 0
  }

  def size
    bookmarks.size
  end
    
  def poster_path
    # this is fairly expensive (lots of little queries) but probably okay
    # for now(?) 
    if false
      videos = bookmarks.map { |bookmark| bookmark.video }
      paths = videos.map { |v| v.poster_path }.compact
      paths.empty? ? nil : paths[rand(paths.size)]
    else
      marks = bookmarks.find :all,
                             :include => { :video => :assets }
      paths = marks.map { |m| m.video.poster_path }.compact
      paths.empty? ? nil : paths[rand(paths.size)]
    end
  end

end

