class Tag < ActiveRecord::Base

  has_many :taggings, :dependent => :destroy
  has_many :videos, :through => :taggings

  def self.map *args
    tags = []
    args = Array(args)
    args.each do |string|
      string.split( /\s*[;,]\s*/ ).each do |arg|
        tag = find_by_text arg
        if !tag
          tag = Tag.new :text => arg
        end
        tags << tag
      end
    end
    tags
  end

end
