PropertyType.find_all_by_name("foo").each do |pt|
  pt.destroy
end
raise "hell" if !PropertyType.find_by_name("foo").nil?

Library.transaction do

  PropertyType.create!( :name => "foo",
                         :property_class_id => 1 )

  PropertyType.create( :name => "foo",
                        :property_class_id => 1 )

  raise ActiveRecord::Rollback

end

raise "hell" if !PropertyType.find_by_name("foo").nil?
