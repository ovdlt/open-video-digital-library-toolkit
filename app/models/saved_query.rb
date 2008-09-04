class SavedQuery < ActiveRecord::Base
  belongs_to :user
  belongs_to :descriptor
  validates_presence_of :user
  validate do |sq|
    !sq.query_string.blank? or !sq.descriptor_id.nil? or
      sq.errors.add_to_base( "can only save searches that have query terms " +
                             "and/or descrptors" )
  end
end
