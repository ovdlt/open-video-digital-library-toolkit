class LibraryController < ApplicationController

  def show
    @library = Library.find :first
  end

  def update
    @library = Library.find :first
    if p = params[:library]
      @library.update_attributes params[:library]
    end
    render :action => :show
  end

end
