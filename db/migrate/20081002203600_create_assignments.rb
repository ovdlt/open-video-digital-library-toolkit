class CreateAssignments < ActiveRecord::Migration

  class DescriptorsVideos < ActiveRecord::Base
  end

  def self.up
    create_table :assignments do |t|
      t.integer :descriptor_id, :null => false
      t.integer :video_id, :null => false
      t.timestamps
    end

    add_index :assignments, [ :descriptor_id, :video_id ],
              :unique => true
    add_index :assignments, [ :video_id, :descriptor_id ],
              :unique => true

    begin
      ( DescriptorsVideos.find :all ).each do |ur|
        if !Assignment.find_by_descriptor_id_and_video_id ur.descriptor_id,
                                                           ur.video_id
          Assignment.create! :descriptor_id => ur.descriptor_id,
                              :video_id => ur.video_id
        end
      end
    rescue
      down
      raise
    end

  end

  def self.down
    drop_table :assignments
  end
end
