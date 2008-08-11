class Descriptor < ActiveRecord::Base

  belongs_to :descriptor_type

  # Don't do this ... don't want to load all the videos everytime we
  # talk about this descriptor ...
  
  has_and_belongs_to_many :videos

  def most_recent
    # bad idea ...
    ( videos.sort { |a,b| a.created_at - b.created_at } )[0]
  end

end
