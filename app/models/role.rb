class Role < ActiveRecord::Base
  has_many :permissions, :dependent => :destroy  
  has_many :users, :through => :permissions
end
