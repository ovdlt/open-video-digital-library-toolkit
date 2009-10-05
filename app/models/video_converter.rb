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
          print "mkdir #{root}/#{subdir}\n"
          FileUtils.mkdir_p "#{root}/#{subdir}"
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
