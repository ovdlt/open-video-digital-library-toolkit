class Search < ActiveRecord::Base

  belongs_to :user
  has_many :criteria

  validates_presence_of :user_id

  def initialize attributes = {}
    super()
    attributes.each do |k,v|
      case k
      when "criteria"
        load_criteria v
      else; raise "hell #{k.inspect}"
      end
    end

  end

  def descriptor_value_id= dv
    @descriptor_value_ids = [ dv ]
  end

  def to_params
    if id and !changed
      { :search_id => id }
    else
      raise "hell"
      hash = {}
      @descriptor_value_ids.each do |dv_id|
        hash["search[descriptor_value_id][]"] = dv_id
      end
      hash
    end
  end

  def criteria
    @criteria or []
  end

  private

  def load_criteria map
    @criteria = []
    map.each do |k,v|
      case k
      when "text"
        v.each do |t|
          @criteria << Criterion.new( :text => v )
        end
      when "property_type"
        v.each do |pt_id,dvs|
          dvs.each do |dv_id|
            @criteria << Criterion.new( :property_type_id => pt_id,
                                          :integer_value => dv_id )
          end
        end
      when "duration"
        v.each do |d|
          @criteria << Criterion.new( :duration => d )
        end
      else raise "hell #{k}"
      end
    end
  end

end
