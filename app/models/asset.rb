class Asset < ActiveRecord::Base

  belongs_to :video

  ASSET_DIR = ::ASSET_DIR

  SURROGATE_DIR = ::SURROGATE_DIR
  SURROGATE_PREFIX = File.dirname( SURROGATE_DIR )

  FILE_PREFIX =  "file:///"

  validates_uniqueness_of :uri
  validate :must_have_valid_path
  validate :must_exist_on_disk

  before_save do |asset|
    asset.size ||= File.size(asset.absolute_path)
  end
  
  class << self
    
    def uncataloged_files( params = {} )

      list = list_dir params

      options = { :select => "uri" }

      if params[:q]
        options.merge!( { :conditions => [ "uri like ?", "%#{params[:q]}%" ] } )
      end

      assets = Asset.find :all, options
      assets = assets.map { |a| a.uri }


      a = ( list_dir( params ) - assets ).sort

      if params[:limit]
        first = 0
        if params[:page]
          first = (params[:page].to_i)*params[:limit].to_i
        end
        a[first,params[:limit].to_i]
      else
        a
      end
      
    end

  private

    def list_dir params

      list = Dir.glob("#{ASSET_DIR}/**/*").map do |filename|
        File.directory?( filename ) ? [] : filename
      end

      list.flatten!
      
      list = list.map do |f|
        if f.index(ASSET_DIR) == 0
          f[ASSET_DIR.length+1,f.length]
        else
          []
        end
      end

      list.flatten!

      if ( q = params[:q] )
        q = q.downcase
        list.reject! do |file|
          p = file.downcase
          q = q.downcase
          p.index( q ) == nil
        end
      end

      list = list.map do |f|
        FILE_PREFIX + f
      end

      list

    end

  end

  def valid_path?
    begin
      video_path = Pathname.new File.expand_path(ASSET_DIR)
      Pathname.new(File.expand_path(absolute_path)).ascend do |path|
        return true if path == video_path
      end
    rescue ArgumentError; end
    return false
  end
  
  def absolute_path
    File.expand_path(File.join(Asset::ASSET_DIR,relative_path))
  end

  def relative_path
    raise ArgumentError if !uri.starts_with? FILE_PREFIX
    uri[FILE_PREFIX.length,uri.length-FILE_PREFIX.length]
  end

  def filename
    File.basename(relative_path)
  end

  def encoding
    nil
  end

  def asset_format
    encoding and encoding.text or begin
      p = File.extname(relative_path)
      p[1...p.length].upcase
    end
  end

  def to_json options = nil
    hash = attributes.dup
    hash["size"] = ( size or File.size(absolute_path) )
    hash["asset_format"] = asset_format
    { "asset" => hash }.to_json( options )
  end

  private
  
  def must_have_valid_path
    errors.add_to_base("The path must point to a valid file") if !valid_path?
  end

  def must_exist_on_disk
    if valid_path?
      errors.add_to_base("The file does not exist on disk") \
        if !File.exists?(absolute_path)
    end
  end
    
end


