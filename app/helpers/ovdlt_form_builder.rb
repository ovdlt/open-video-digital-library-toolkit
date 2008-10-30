class OvdltFormBuilder < ActionView::Helpers::FormBuilder

  def criterion field, *args
    case field
    when :text
      @template.content_tag :div do
        v = @template.content_tag :p, "foobar"
        __in_erb_template = true
        p "called", v, defined?( __in_erb_template )
      end
    else; raise "hell"
    end
  end

end
