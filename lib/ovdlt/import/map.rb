module OVDLT
module Import

  class Map

    def initialize yaml
      @yaml = yaml
      @map = YAML::load yaml
      # puts YAML::dump @map
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
                    video[header] = value
                  when Hash
                    if header.size == 1
                      key = header.keys.first
                      range = header.values.first
                      if key =~ /^[a-z]/
                        case range
                        when Hash
                          if range.has_key? value
                            video[key] = value
                          else
                            pp range
                            raise "can't map #{value} for #{key}"
                          end
                        when nil;
                        else; raise "hell range #{range.class} #{range}"
                        end
                      elsif key =~ /^[A-Z]/
                        raise "hell class #{key}"
                      else
                        raise "hell #{key}"
                      end
                    else
                      raise "hell #{header.size}"
                    end
                  else; raise "hell: #{headers[index]} #{header.class}: #{header}"
                  end
                  video[header] = value
                end
              end
            end

            if video.sentence.blank?
              if !video.description.blank?
                video.sentence = video.description
                video.sentence.sub! /([^\.]+\.).*/, '\1'
              end
            end

            video.save!

          end
        end

      ensure
        csv.close if csv
      end

    end

  end

end
end
