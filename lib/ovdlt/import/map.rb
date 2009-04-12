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
        csv.each do |row|
          row.each do |value|
            header = true

            if !@map.has_key? value
              puts "#{value} is not a header element"
              header = false
            end

            if header
              nil
            else
              nil
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
