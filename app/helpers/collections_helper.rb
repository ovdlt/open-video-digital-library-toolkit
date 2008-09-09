module CollectionsHelper
  
  def partial
    params[:action].singularize
  end

  def mailto collection
    by = User.find_by_id(collection.user_id).login
    subject = url_encode "Playlist entitled #{collection.title} by #{by}"
    body = url_encode <<EOS
Playlist link: #{collection_url(collection)}
Link to #{Library.title}: #{root_url}
EOS
    "mailto:?subject=#{subject}&body=#{body}"
  end

end
