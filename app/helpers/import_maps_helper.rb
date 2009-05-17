module ImportMapsHelper

  def fields 
    @fields ||= begin
    [ "not mapped" ] +
    ((  %w(title sentence abstract duration local_id donor 
              alternative_title series_title audience classification
              language_note creation_credits participation_credits
              preservation_note transcript notes public tags Asset) +
            PropertyType.find(:all).to_a.map(&:name) ).
        sort {|a,b| a.downcase <=> b.downcase || a <=> b })

    end
  end

  def primary value
    case value
    when Hash; value = value.keys[0]
    end
    value
  end

  def secondary value
    case value
    when Hash; value.values[0]
    else; nil
    end
  end

  def field_options
    fields.map do |field|
      [ field, field ]
    end
  end

  def tertiary value
    set = PropertyType.find_by_name value
    if set
      set.values.map(&:to_s).sort {|a,b| a.downcase <=> b.downcase || a <=> b }
    else
      raise "#{value.inspect}"
    end
  end

end
