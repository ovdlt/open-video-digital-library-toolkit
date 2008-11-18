module HomeHelper

  def public_collections_count
    Collection.count :conditions => { :public => true }
  end

end
