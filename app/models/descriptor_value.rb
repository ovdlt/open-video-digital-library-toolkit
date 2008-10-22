class DescriptorValue < ActiveRecord::Base

  validates_uniqueness_of :text, :scope => :property_type_id
  validates_presence_of :text
  validates_numericality_of :property_type_id, :greater_than => 0

  belongs_to :property_type

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

  def videos
    
    if false
      properties.find( :all,
                       :include => :video ).
        map(&:video)
    else
      Video.find :all,
                  :joins => ", properties ps",
                  :conditions =>
                        "videos.id = ps.video_id and " +
                        "ps.property_type_id = #{property_type_id} and " +
                        "ps.integer_value = #{id}"
    end
  end

end
