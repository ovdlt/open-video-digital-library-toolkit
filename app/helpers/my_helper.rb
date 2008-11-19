module MyHelper

  def link_to_action action
    link_to_unless params[:action] == action.to_s,
        action.to_s.humanize.capitalize,
        self.send( "#{action}_my_path".to_sym )
  end

end

