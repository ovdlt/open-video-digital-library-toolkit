class AssetsController < ApplicationController

  require_role "admin", :for_all_except => []

  def new
    @video = params["video_id"].to_i == 0 ? session["new_video"] \
                                          : Video.find( params["video_id"] )
    p @video
    @files  = Asset.list_uncataloged_files
  end

  def uncataloged
    options = { :limit => 10 }
    
    if params[:limit]
      options[:limit] = params[:limit]
    end

    assets = Asset.list_uncataloged_files params

    render :text => ( assets.map { |a| File.basename(a.path) } ).join(" ")

  end

end
