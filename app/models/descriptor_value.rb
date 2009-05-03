class DescriptorValue < ActiveRecord::Base

  validates_uniqueness_of :text, :scope => :property_type_id
  validates_presence_of :text

  def validate 
    if ( property_type_id.nil? or
         property_type_id < 1 ) and
       ( property_type.nil? or
         property_type.id.nil? or
         property_type.id < 1 )
      errors.add_to_base "Descriptor type is invalid"
    end
  end

  before_save do |dv|
    if !dv.attributes.include? "priority"
      dv.priority = DescriptorValue.maximum("priority")+1;
    end
  end

  belongs_to :property_type
  default_scope :order => "priority desc, text asc"

  has_many :properties,
           :through => :property_type do

    def sql_conditions
      conditions = "properties.integer_value = #{@owner.id}"
      if base = super
        conditions = "(" + [ conditions, base ].join(")AND(") + ")"
      end
      conditions
    end

  end

  def count public
    if public
      public = "and videos.public = true"
    else
      public = ""
    end
    Video.count :joins => ", properties ps",
                 :conditions =>
                      "videos.id = ps.video_id and " \
                      "ps.property_type_id = #{property_type_id} and " \
                      "ps.integer_value = #{id} #{public}"
  end

  def videos public
    if public
      public = "and videos.public = true"
    else
      public = ""
    end
    Video.find :all,
                :joins => ", properties ps",
                :conditions =>
                      "videos.id = ps.video_id and " \
                      "ps.property_type_id = #{property_type_id} and " \
                      "ps.integer_value = #{id} #{public}"
  end

  def self.browse_order= ids
    objects = {}
    self.find( ids ).each { |object| objects[object.id] = object }
    objects = ids.map { |id| objects[id] }
    priorities = objects.map(&:priority)
    priorities = priorities.sort.reverse
    objects.each { |o| o.priority = priorities.shift }
    # this should be transactional, but ...
    objects.each { |o| o.save! }
  end

end
