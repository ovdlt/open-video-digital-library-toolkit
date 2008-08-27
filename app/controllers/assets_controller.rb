class AssetsController < ApplicationController

  require_role "admin", :for_all_except => []

  def _new
    @video = params["video_id"].to_i == 0 ? session["new_video"] \
                                          : Video.find( params["video_id"] )
    p @video
    @files  = Asset.list_uncataloged_files params

    

  end

  def uncataloged
    options = { :limit => 10 }
    
    if params[:limit]
      options[:limit] = params[:limit]
    end

    assets = Asset.list_uncataloged_files params

    a = assets.map { |a| File.basename(a[8,a.length]) }
    a.sort!

    render :text => ( a ).join(" ")

  end

  def create
    video_id = params[:video_id]
    if !video_id.nil? and video_id != "0"
      @video = Video.find video_id
    end
    @video ||= ( session["working_video"] ||= Video.new :title => "foobar" )
    @video.id ||= 0
    
    @video.assets << Asset.new( :uri => "file:///" + params[:filename] )

    p @video

    redirect_to new_video_path
  end

end
