require 'erubis'

YAML::add_private_type( "Proc" ) do |type, string|
  eval "Proc.new #{string}"
end

module OVDLT
module Import

  class Map

    def initialize yaml
      @yaml = yaml
      # p yaml
      @map = YAML::load( Erubis::Eruby.new( yaml.read ).result )
      # puts YAML::dump @map
    end

    def set object, field, value
      if object.attributes.has_key? field
        object[field] = value
      else
        object.send "#{field}=".to_sym, value
      end
    end

    def import file

      headers = true
      
      csv = nil

      begin
        csv = FasterCSV.new file
        
        headers = []

        csv.each do |row|

          header = true

          next if row.compact.empty?

          row.each do |value|
            if !value.nil? and !@map.has_key? value
              header = false
            end
          end

          if header
            
            row.each_with_index do |value, index|
              if !value.nil?
                headers[index] = value
              end
            end

          else

            video = Video.new

            row.each_with_index do |value, index|
              if !value.nil?
                header = @map[headers[index]]
                if !header.nil?
                  case header
                  when String
                    if header =~ /^[A-Z]/
                      video.properties << (p = Property.build( header, value ))
                    elsif header != "nil"
                      set video, header, value
                    end
                  when Hash
                    if header.size == 1
                      key = header.keys.first
                      range = header.values.first
                      if key =~ /^[a-z]/
                        case range
                        when Hash
                          if range.has_key? value
                            set video, key, range[value]
                          else
                            pp range
                            raise "can't map #{value} for #{key}"
                          end
                        when Proc;
                          set video, key, range.call( value )
                        else
                          raise "hell range #{range.class} #{range}"
                        end
                      elsif key =~ /^[A-Z]/
                        case range
                        when String;
                        when Hash;
                          if range.has_key? value
                            value = range[value]
                          else
                            raise "can't map #{value} for #{key}"
                          end
                        else raise "bad range: #{range} (for #{key})"
                        end
                        video.properties << (p = Property.build( key, value ))
                      else
                        raise "hell #{key}"
                      end
                    else
                      raise "hell #{header.size}"
                    end
                  else; raise "hell: #{headers[index]} #{header.class}: #{header}"
                  end
                end
              end
            end

            if video.sentence.blank?
              if !video.abstract.blank?
                video.sentence = video.abstract.sub /([^\.]+\.).*/, '\1'
              end
            end

            if video.local_id
              Video.find_all_by_local_id( video.local_id ).each { |v| v.destroy }
            end

            p video.tags
            
            p "a"
            x = video.save
            p "b"
            if !x
              puts "Could not create video"
              if !video.errors.empty?
                puts "Video Errors:"
                video.errors.each_full { |msg| puts msg }
              end
              property_errors = video.properties.map { |p| p.errors }
              empty = property_errors.inject(true) { |prev,e| prev && e.empty? }
              if !empty
                puts "Property Errors"
                property_errors.each do |pe|
                  pe.each_full { |msg| puts msg }
                end
              end
              puts "Video: #{video.inspect}"
            else
              if video.local_id
                puts "#{video.local_id} => #{video.id}"
              else
                puts "#{video.id}"
              end
            end

          end
        end

      ensure
        csv.close if csv
      end

    end

  end

end
end
