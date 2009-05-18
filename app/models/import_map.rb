class ImportMap < ActiveRecord::Base

  validate do |map|
    begin
      YAML.load StringIO.new( map.yml )
    rescue Exception => e
      map.errors.add :yml, e.message
    end
  end 

end
