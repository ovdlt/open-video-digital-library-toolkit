class Criterion < ActiveRecord::Base

  belongs_to :search

  # caught by database
  # validates_presence_of :search_id

  # could be made polymorphic, etc.

  def text= t
    self.criterion_type = "text"
    write_attribute "text", t
  end

  def duration= d
    self.criterion_type = "duration"
    write_attribute "duration", d
  end

  def tag= t
    self.criterion_type = "tag"
    write_attribute "tag", t
  end

  def property_type_id= pt_id
    self.criterion_type = "property_type"
    write_attribute "property_type_id", pt_id
  end

  def public= v
    self.criterion_type = "public"
    write_attribute "public", v
  end

  def add_to_params hash
    save = hash
    case criterion_type
    when "text"
      if !text.blank?
        hash["text"] ||= []
        hash["text"] << text
      end
    when "duration";
      if !duration.blank?
        hash["duration"] ||= []
        hash["duration"] << duration
      end
    when "tag";
      if !tag.blank?
        hash["tag"] ||= []
        hash["tag"] << tag
      end
    when "public";
      if [true,false].include?(public)
        hash["public"] ||= []
        hash["public"] << public
      end
    when "property_type";
      if !integer_value.blank?
        hash["property_type"] ||= {}
        hash = hash["property_type"]
        hash["#{property_type_id}"] ||= []
        hash["#{property_type_id}"] << integer_value
      end
    else raise "not implemenated: #{criterion_type}"
    end
    save
  end

end
