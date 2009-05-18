class ImportController < ApplicationController

  require_role [ :admin ]

  def create
    action = params[:commit]

    case action
    when "Edit"
      redirect_to edit_import_map_path( params[:map] )
    when "New";
      redirect_to new_import_map_path
    when "import";
    else render_nothing
    end

  end

end
