class HomeController < ApplicationController

  PAGES = :about, :contact, :privacy, :news

  [ :about, :contact, :privacy, :news ].each do |page|
    define_method page do
      @page = page
      @value = @library.send @page
      render :action => "page"
    end
  end

  require_role :admin, :for => :update

  def update

    attribute = params[:attribute] && params[:attribute].to_sym

    if !PAGES.include?(attribute) or !(v = params[:value])
      render_nothing
    end

    @library[attribute] = v

    if params[:commit] == "save"
      @library.save
      redirect_to url_for :action => attribute
    else
      self.send attribute
    end

  end

end
