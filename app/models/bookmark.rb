class Bookmark < ActiveRecord::Base

  belongs_to :video
  belongs_to :collection, :touch => :updated_at
  has_one :user, :through => :collection

  before_save do |bookmark|
    if !bookmark.attributes.include? "priority"
      bookmark.priority = collection.bookmarks.maximum("priority")+1;
    end
  end

  def sentence
    if !annotation.blank?
      annotation
    else
      video.sentence
    end
  end

  def self.set_order user_id, ids
    p user_id, ids

    objects = {}

    begin
      found = self.find( ids,
                         :include => :collection,
                         :conditions => "collection_id = collections.id and collections.user_id = #{user_id}"
                         )
    rescue ActiveRecord::RecordNotFound
      return false
    end    

    found.each { |object| objects[object.id] = object }

    objects = ids.map { |id| objects[id] }
    priorities = objects.map(&:priority)
    priorities = priorities.sort.reverse
    objects.each { |o| o.priority = priorities.shift }

    # this should be transactional, but ...
    objects.each { |o| o.save! }
  end

end
