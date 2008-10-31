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

end
