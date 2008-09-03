module ApplicationHelper

  def tab_for field
    render :partial => "/shared/tab", :object => field
  end

  def div_for field
    render :partial => "/shared/div", :object => field
  end

end
