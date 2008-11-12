class SavedQueriesController < ApplicationController

  def create
    if current_user.nil?
      flash[:error] = "You must be logged in to save a search"
    else
      search = Search.new params[:search]
      current_user.searches << search
      if current_user.save
        flash[:notice] = "Search saved"
      else
        flash[:error] = "Error saving search"
      end
    end
    redirect_to :back
  end

  def destroy
    if !current_user
      render_missing
      return
    end

    if params[:id].blank? or params[:id] == "0"
      render_missing
      return
    end

    search = nil
    begin
      search = Search.find params[:id]
    rescue ActiveRecord::RecordNotFound
      render_missing
      return
    end

    if search.user_id != current_user.id
      render_missing
      return
    end

    search.destroy

    flash[:notice] = "Search deleted"

    redirect_to :back
  end

end
