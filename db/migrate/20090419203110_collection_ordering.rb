class CollectionOrdering < ActiveRecord::Migration

  def self.up
    add_column :collections, :priority, :int, :null => false, :default => 0
    add_column :collections, :featured_priority, :int, :null => false, :default => 0

    remove_index :collections, [ :featured, :featured_on ]

    add_index :collections, [ :featured, :featured_priority, :featured_on ],
              :name => "featured_collections"
    add_index :collections, [ :priority, :created_at ]
    add_index :collections, [ :priority, :updated_at ]
    
    add_column :videos, :featured_priority, :int, :null => false, :default => 0

    remove_index :videos, [ :featured, :featured_on ]

    add_index :videos, [ :featured, :featured_priority, :featured_on ],
              :name => "featured_videos"

    add_column :bookmarks, :priority, :int, :null => false, :default => 0

    add_index :bookmarks, [ :collection_id, :priority, :created_at ],
              :name => "bookmark_order"
  end

  def self.down

    remove_index :collections, :name => "featured_collections"
    remove_index :collections, [ :priority, :created_at ]
    remove_index :collections, [ :priority, :updated_at ]
    
    remove_index :videos, :name => "featured_videos"

    remove_index :bookmarks, :name => "bookmark_order"

    remove_column :collections, :priority
    remove_column :collections, :featured_priority
    remove_column :videos, :featured_priority
    remove_column :bookmarks, :priority

    add_index :collections, [ :featured, :featured_on ]
    add_index :videos, [ :featured, :featured_on ]

  end

end
