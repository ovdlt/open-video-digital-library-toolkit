class Asset < ActiveRecord::Base

  belongs_to :video

  ASSET_DIR = ::ASSET_DIR

  validates_uniqueness_of :uri
  validate :must_have_valid_path
  validate :must_exist_on_disk

  before_save do |asset|
    asset.size ||= File.size(asset.path)
  end
  
  def self.list_uncataloged_files
    list = Dir.glob("#{ASSET_DIR}/*").map { |filename| File.new(filename) }
    list.reject! {|file| Asset.exists?(:uri => "file:///" + File.basename(file.path)) }
    list.partition { |file| File.directory?(file) }.flatten!
  end
  
  def self.paginate_uncataloged_files params
    list = list_uncataloged_files
    perpage = params[:page_page] || "10"
    pagenum = params[:page] || "1"

    if !params[:page].nil?
      a = (params[:page].to_i - 1) * perpage.to_i
      b = a + (perpage.to_i-1)
    else
      a = 0
      b = a + (perpage.to_i-1)
    end
    WillPaginate::Collection.new(pagenum,
                                    perpage,
                                    list.length.to_s).concat(list[a..b])
  end
  
  def valid_path?
    video_path = Pathname.new File.expand_path(ASSET_DIR)
    Pathname.new(File.expand_path(path)).ascend do |path|
      return true if path == video_path
    end
    return false
  end
  
  FILE_PREFIX =  "file:///"
  FILE_PREFIX_LENGTH = FILE_PREFIX.length

  def filename
    raise ArgumentError if !uri.starts_with? FILE_PREFIX
    uri[FILE_PREFIX_LENGTH,uri.length-FILE_PREFIX_LENGTH]
  end

  def path
    File.expand_path(File.join(Asset::ASSET_DIR,filename))
  end

  def encoding
    nil
  end

  def asset_format
    encoding and encoding.text or begin
      p = File.extname(path)
      p[1...p.length].capitalize
    end
  end

  private
  
  def must_have_valid_path
    errors.add_to_base("The path must point to a valid file") if !valid_path?
  end

  def must_exist_on_disk
    if valid_path?
      errors.add_to_base("The file does not exist on disk") \
        if !File.exists?(path)
    end
  end
    
end


