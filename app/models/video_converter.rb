class VideoConverter

  class << self

    def run directory = nil
      if !File.exist? "tmp/vc.lock"
        system "touch tmp/vc.lock"
      end
      f = File.open "tmp/vc.lock"
      result = f.flock File::LOCK_EX | File::LOCK_NB
      if !result
        $stderr.print "lock already taken: exiting\n"
        exit
      end

      directories = nil
      if !directory.blank?
        # FIX for windows if we keep this
        if !Dir[ File.join( ASSET_DIR, directory ) ].empty?
          directories = [ File.join( ASSET_DIR, directory ) ]
          if !Dir[ File.join( SURROGATE_DIR, directory ) ].empty?
            FileUtils.rm_rf File.join( SURROGATE_DIR, directory )
          end
        else
          if directory.index("public/assets") != 0
            raise "#{directory} not found"
          else
            directory = directory[ "public/assets".length, directory.length ]
            if !Dir[ File.join( ASSET_DIR, directory ) ].empty?
              directories = [ File.join( ASSET_DIR, directory ) ]
              if !Dir[ File.join( SURROGATE_DIR, directory ) ].empty?
                FileUtils.rm_rf File.join( SURROGATE_DIR, directory )
              end
            else
              raise "#{directory} not found"
            end
          end
        end
      end
      directories ||= self.directories
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

        [ "flash", "fastforwards", "excerpts", "stills" ].each do |subdir|
          FileUtils.mkdir_p "#{root}/#{subdir}"
          case subdir
          when "flash"
            converter "-if #{ASSET_DIR}/#{directory} -of #{root}/#{subdir}/#{directory}.flv -interval 1"
          when "fastforwards"
            converter "-if #{ASSET_DIR}/#{directory} -of #{root}/#{subdir}/#{directory}.flv"
          when "excerpts"
            converter "-if #{ASSET_DIR}/#{directory} -of #{root}/#{subdir}/#{directory}.flv  -interval 1 -time_segment 12 22"
          when "stills"
            converter "-if #{ASSET_DIR}/#{directory} -of #{root}/#{subdir}/#{directory}.jpg -scale_x 320"
          end
        end

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

    def converter string
      cmd = "#{RAILS_ROOT}/lib/ovsurgen " + string
      print cmd
      result = system cmd
      if result != true
        $stderr.print "conversion failed (#{result.inspect}): exit status: #{$?}\n"
      end
    end

  end

end
