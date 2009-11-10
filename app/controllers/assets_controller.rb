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
    if !@asset or !@asset.video
      render_missing
      return
    end

    @asset.video.downloads += 1
    @asset.video.last_downloaded = Time.now
    @asset.video.save

    if (!current_user or !current_user.has_role?([:admin,:cataloger])) and
        !@asset.video.public?
      render_missing
      return
    end

    if current_user and
       current_user.downloads.all_videos.find_by_id(@asset.video_id).nil?
      current_user.downloads.all_videos << @asset.video
      current_user.downloads.save!
      current_user.save!
    end

    # There's got to be a better way to do this
    redirect_to ( ActionController::Base.relative_url_root or "" ) +
               '/assets/' + @asset.relative_path
  end

end
