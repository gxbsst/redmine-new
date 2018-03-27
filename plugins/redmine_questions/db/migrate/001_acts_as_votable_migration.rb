class ActsAsVotableMigration < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.create_votable_table
    add_column :messages, :cached_votes_total, :integer, :default => 0
    add_column :messages, :cached_votes_up, :integer, :default => 0
    add_column :messages, :cached_votes_down, :integer, :default => 0
    add_index  :messages, :cached_votes_total
    add_index  :messages, :cached_votes_up
    add_index  :messages, :cached_votes_down
  end

  def self.down
    ActiveRecord::Base.drop_votable_table
    remove_column :messages, :cached_votes_total
    remove_column :messages, :cached_votes_up
    remove_column :messages, :cached_votes_down
  end
end
