class VideoConverter

  class << self

    def run
      directories.each do |directory|
        convert trim(directory)
      end
    end

    def directories
      Dir[ASSET_DIR+"/*"]
    end

    def convert directory
      return if directory.blank?
      if asset(directory)
        print "skipping #{directory} ...\n"
      else
        print "converting #{directory} ...\n"

        root = File.join(SURROGATE_DIR,directory)

        [ "flash", "fastfowards", "excerpts", "stills" ].each do |subdir|
          FileUtils.mkdir_p "#{root}/#{subdir}"
          case subdir
          when "flash"
            system "#{RAILS_ROOT}/lib/KFQuilt -if #{ASSET_DIR}/#{directory} -of #{root}/#{subdir}/0002.0001_H.flv -interval 1"
          when "fastfowards"
            system "#{RAILS_ROOT}/lib/KFQuilt -if #{ASSET_DIR}/#{directory} -of #{root}/#{subdir}/0002.0001_H.flv"
          when "excerpts"
            system "#{RAILS_ROOT}/lib/KFQuilt -if #{ASSET_DIR}/#{directory} -of #{root}/#{subdir}/0002.0001_H.flv  -interval 1 -time_segment 10 20"
          when "stills"
            print "#{RAILS_ROOT}/lib/KFQuilt -if #{ASSET_DIR}/#{directory} -of #{root}/#{subdir}/#{directory}.jpg -scale_x 320\n"
            system "#{RAILS_ROOT}/lib/KFQuilt -if #{ASSET_DIR}/#{directory} -of #{root}/#{subdir}/#{directory}.jpg -scale_x 320"
          end
        end

        exit
      end
    end

    private

    def trim directory
      if directory.index( ASSET_DIR ) == 0
        directory[ASSET_DIR.length+1,directory.length]
      else
        nil
      end
    end

    def asset directory
      !Dir[File.join(SURROGATE_DIR,directory)].empty?
    end

  end

end
