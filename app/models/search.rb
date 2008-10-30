class Search < ActiveRecord::Base

  belongs_to :user
  has_many :criteria

  validates_presence_of :user_id

end
