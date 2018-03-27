class AddTaggingMigration < ActiveRecord::Migration
  def up
    ActiveRecord::Base.create_taggable_table
  end

  def down
  end
end
