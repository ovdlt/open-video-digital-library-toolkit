class Assignment < ActiveRecord::Base
  belongs_to :descriptor
  belongs_to :video
end
