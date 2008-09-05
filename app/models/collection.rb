class Collection < ActiveRecord::Base

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
    
end

