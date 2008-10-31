class OvdltFormBuilder < ActionView::Helpers::FormBuilder

  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper

  # All these only handle single values though the model
  # code has some suport for MV (so that url's dont' change)

  def criterion field, *args
    case field
    when :text
      v = object.criteria.detect do |criterion| 
        criterion.type == :text
      end
      v = v.text if v

      text_field_tag "#{object_name}[criteria][text][]", v

    when :duration

      v = object.criteria.detect do |criterion| 
        criterion.type == :duration
      end
      v = v.duration if v

      options =
        options_for_select( [ [ "-- any duration --", nil ],
                              [ "less than 1 minute", 1 ],
                              [ "between 1 and 2 minutes", 2 ],
                              [ "between 2 and 5 mintues", 5 ],
                              [ "between 5 and 10 mintues", 10 ],
                              [ "between 10 and 30 mintues", 30 ],
                              [ "between 30 and 60 minutes", 60 ],
                              [ "longer than 1 hour", -1 ],
                            ], v.to_i )
      
      name = "#{object_name}[criteria][#{field}][]"

      @template.content_tag( :select,
                             options,
                             :name => name )

    when PropertyType
      current = object.criteria.detect do |criterion| 
        criterion.type == :property_type &&
        criterion.property_type_id.to_i == field.id
      end
      current = current.integer_value.to_i if current

      values = field.values
      values = values.map { |v| [ v.id, v.text ] }
      values = [ [ nil, "-- any --" ] ] + values

      options =
        options_from_collection_for_select values, :first, :last, current

      name = "#{object_name}[criteria][property_type][#{field.id}][]"

      @template.content_tag( :select,
                             options,
                             :name => name )

    else;
    end
  end
  
end
