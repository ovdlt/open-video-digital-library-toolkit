class Rights < ActiveRecord::Base

  validates_presence_of :statement
  validates_presence_of :license

end
