class Search < ActiveRecord::Base

  belongs_to :user
  has_many :criteria

  validates_presence_of :user_id

  def initialize attributes = {}
    super()
    attributes ||= {}
    attributes.each do |k,v|
      case k.to_s
      when "criteria"
        load_criteria v
      when "user_id"
        self.user_id = v
      when "title"
        self.title = v
      else
        criteria << Criterion.new( k => v )
      end
    end
  end

  def as_inputs hash, name
  end

  def add_to_params hash, name
    if id and !changed
      hash["#{name}_id"] = id
    else
      hash[name] ||= {}
      hash[name]["criteria"] ||= {}
      criteria.each do |criterion|
        criterion.add_to_params hash[name]["criteria"]
      end
    end
    hash
  end

  private

  def load_criteria hash
    hash.each do |k,v|
      case k
      when "text"
        v.each do |t|
          !t.blank? and criteria << Criterion.new( :text => t )
        end
      when "property_type"
        v.each do |pt_id,dvs|
          dvs.each do |dv_id|
            !dv_id.blank? and criteria << Criterion.new( :property_type_id => pt_id,
                                                           :integer_value => dv_id )
          end
        end
      when "public"
        v.each do |d|
          criteria << ( cx = Criterion.new( :public => d ) )
        end
      when "duration"
        v.each do |d|
          !d.blank? and criteria << Criterion.new( :duration => d )
        end
      else raise "hell #{k}"
      end
    end
  end

end
