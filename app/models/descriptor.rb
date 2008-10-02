class Descriptor < ActiveRecord::Base

  validates_presence_of :text

  belongs_to :descriptor_type

  # validates_presence_of :descriptor_type
  # can't(?) make this work but the db should catch it

  # Don't do this ... don't want to load all the videos everytime we
  # talk about this descriptor ...
  
  has_many :assignments, :dependent => :destroy
  has_many :videos, :through => :assignments

  def most_recent
    # bad idea ... see above ...
    # and don't know why the reload is necessary to get the
    # time stamps: if the recode for paging doesn't get rid of the
    # need for this code, track it down ...
    videos.each &:reload
    ( videos.sort { |a,b| a.created_at - b.created_at } )[0]
  end

  def random exclude = []
    candidates = videos.map &:id
    number = videos.count
    tries = 0
    v = nil
    while tries < number
      r = rand(number)
      v = videos[r]
      if !exclude[v.id]
        exclude[v.id]= true
        return v
      end
      tries += 1
    end
    return nil
  end

end
