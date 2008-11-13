class AddVideoAttributes < ActiveRecord::Migration

  def self.up
    add_column :videos, :alternative_title, :string
    add_column :videos, :series_title, :string
    add_column :videos, :audience, :string
    add_column :videos, :classification, :string
    add_column :videos, :language_note, :string

    add_column :videos, :creation_credits, :text
    add_column :videos, :participation_credits, :text
    add_column :videos, :preservation_note, :text

    add_column :videos, :transcript, :text
    add_column :videos, :notes, :text
  end

  def self.down
    remove_column :videos, :notes
    remove_column :videos, :transcript

    remove_column :videos, :preservation_note
    remove_column :videos, :participation_credits
    remove_column :videos, :creation_credits

    remove_column :videos, :language_note
    remove_column :videos, :classification
    remove_column :videos, :audience
    remove_column :videos, :series_title
    remove_column :videos, :alternative_title
  end

end

# All attributes are text fields. Following attributes are less than 255 chars and should be surfaced on the Details page: alternative_title, series_title, audience, classification, language note. Following attributes are longer than 255 and should be surfaced on Details page: creation_credits, participation_credits, preservation_note. Following attributes are longer than 255 and should not be surfaced on Details page: transcript, notes. Of all of these new attributes, suggest the following be added to full-text search: alternative_title, series_title, creation_credits, participation_credits. 
