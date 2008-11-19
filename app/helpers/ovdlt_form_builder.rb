class OvdltFormBuilder < ActionView::Helpers::FormBuilder

  # All these only handle single values though the model
  # code has some suport for MV (so that url's dont' change)

  def criterion field, options = {}
    case field

    when :text
      v = object.criteria.detect do |criterion| 
        criterion.criterion_type.to_s == "text"
      end
      v = v.text if v

      @template.text_field_tag "#{object_name}[criteria][text][]", v, options.merge( { :id => nil } )

    when :duration

      v = object.criteria.detect do |criterion| 
        criterion.criterion_type.to_s == "duration"
      end

      v = v.duration if v
      v = v.to_i if !v.blank?

      options =
        @template.options_for_select( [ [ "-- any duration --", nil ],
                                        [ "less than 1 minute", 0 ],
                                        [ "between 1 and 2 minutes", 1 ],
                                        [ "between 2 and 5 mintues", 2 ],
                                        [ "between 5 and 10 mintues", 3 ],
                                        [ "between 10 and 30 mintues", 4 ],
                                        [ "between 30 and 60 minutes", 5 ],
                                        [ "longer than 1 hour", 6 ],
                                      ], v )
      
      name = "#{object_name}[criteria][#{field}][]"

      @template.content_tag( :select,
                             options,
                             :name => name )

    when :public
      current = object.criteria.detect do |criterion| 
        criterion.criterion_type.to_s == "public"
      end

      current = current.public if current

      options =
        @template.options_for_select( [ [ "-- any visibility --", nil ],
                                        [ "public", true ],
                                        [ "private", false ],
                                      ], current )

      name = "#{object_name}[criteria][#{field}][]"

      @template.content_tag( :select,
                             options,
                             :name => name )

    when PropertyType
      current = object.criteria.detect do |criterion| 
        criterion.criterion_type.to_s == "property_type" &&
        criterion.property_type_id.to_i == field.id
      end
      current = current.integer_value.to_i if current

      values = field.values
      values = values.map { |v| [ v.id, v.text ] }
      values = [ [ nil, "-- any --" ] ] + values

      options =
        @template.options_from_collection_for_select values, :first, :last, current

      name = "#{object_name}[criteria][property_type][#{field.id}][]"

      @template.content_tag( :select,
                             options,
                             :name => name )

    else;
    end
  end
  
end
