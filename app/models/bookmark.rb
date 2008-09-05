class Bookmark < ActiveRecord::Base
  belongs_to :video
  belongs_to :collection
end
