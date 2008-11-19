class AssetsController < ApplicationController

  require_role [ :admin, :cataloger ], :for_all_except => [ :show ]

  def uncataloged
    options = { :limit => 10 }
    
    if params[:limit]
      options[:limit] = params[:limit]
    end

    if params[:page]
      options[:page] = params[:page]
    end

    if params[:q]
      options[:q] = params[:q]
    end

    assets = Asset.uncataloged_files options

    @assets = assets.map { |a| File.basename(a[8,a.length]) }
    @assets.sort!
  end

  def show
    @asset = Asset.find params[:id]
    if !@asset
      render_missing
      return
    end

    if (!current_user or !current_user.has_role?([:admin,:cataloger])) and
        !@assert.video.public?
      render_missing
      return
    end

    if current_user and
       current_user.downloads.all_videos.find_by_id(@asset.video_id).nil?
      current_user.downloads.all_videos << @asset.video
      current_user.downloads.save!
      current_user.save!
    end
      
    redirect_to "/assets/" + @asset.relative_path
  end

end
