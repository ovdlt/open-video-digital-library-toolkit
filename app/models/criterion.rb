class Criterion < ActiveRecord::Base

  belongs_to :search
  has_one :property

  validates_presence_of :search_id

  def text= t
    @text = t
    @type = :text
  end

  def type
    @type
  end

  def text
    @text
  end

  def duration
    @duratino
  end

  def duration= d
    @duratino = d
    @type = :duration
  end

  def property_type_id
    @property_type_id
  end

  def property_type_id= pt_id
    @property_type_id = pt_id
    @type = :property_type
  end

  def integer_value
    @integer_value
  end

  def integer_value= i
    @integer_value = i
  end

  def add_to_params hash
    save = hash
    case @type
    when :text
      hash["text"] ||= []
      hash["text"] << @text
    when :duration;
      hash["duration"] ||= []
      hash["duration"] << @duration
    when :property_type;
      hash["property_type"] ||= {}
      hash = hash["property_type"]
      hash["#{property_type_id}"] ||= []
      hash["#{property_type_id}"] << @integer_value
    else raise "not implemenated: #{@type}"
    end
    save
  end

end
