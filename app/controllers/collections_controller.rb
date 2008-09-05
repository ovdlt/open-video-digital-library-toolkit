class CollectionsController < ApplicationController

  before_filter :find_and_verify_public_or_user

  private

  def find_and_verify_public_or_user
    if !params[:id] or
        !(@collection = Collection.find_by_id params[:id]) or
        (!@collection.public? and
         (!current_user or @collection.user_id != current_user.id))
      render_missing
    end
    
  end

end
