module MyHelper

  def favorites_teaser
    current_user.favorites.videos[0,5]
  end

end

