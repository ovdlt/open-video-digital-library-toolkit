class AssetsController < ApplicationController

  require_role "admin"

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
    if @asset
      redirect_to "/assets/" + @asset.relative_path
    else
      render_missing
    end
  end

  def _new_
    @video = params["video_id"].to_i == 0 ? session["new_video"] \
                                          : Video.find( params["video_id"] )
    @files  = Asset.uncataloged_files params
  end

 def _create_
    video_id = params[:video_id]
    if !video_id.nil? and video_id != "0"
      @video = Video.find video_id
    end
    @video ||= ( session["working_video"] ||= Video.new :title => "foobar" )
    @video.id ||= 0
    
    @video.assets << Asset.new( :uri => "file:///" + params[:filename] )

    redirect_to new_video_path
  end

end
