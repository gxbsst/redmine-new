require 'active_record'

module RedmineCrm
  module ActsAsVotable #:nodoc:
    module Votable #:nodoc:
      def votable?
        false
      end

      def rcrm_acts_as_votable
        require 'redmine_crm/acts_as_votable/votable'
        include RedmineCrm::ActsAsVotable::Votable

        class_eval do
          def self.votable?
            true
          end
        end
      end

      def create_index(table_name, column_name)
        return if self.connection.index_exists?(table_name, column_name)

        self.connection.add_index table_name, column_name
      end

      def create_votable_table(options = {})
        votes_name_table = options[:votes] || :votes

        if !self.connection.table_exists?(votes_name_table)
          self.connection.create_table(votes_name_table) do |t|
            t.references :votable, :polymorphic => true
            t.references :voter, :polymorphic => true

            t.column :vote_flag, :boolean
            t.column :vote_scope, :string
            t.column :vote_weight, :integer
            t.column :vote_ip, :string

            t.timestamps
          end
        else #if table exists - check existence of separate columns
          fields = {
            :votable_id => :integer,
            :votable_type => :string,
            :voter_id => :integer,
            :voter_type => :string,
            :vote_flag => :boolean,
            :vote_scope => :string,
            :vote_weight => :integer,
            :vote_ip => :string
          }
          fields.each do |name, type|
            if !self.connection.column_exists?(votes_name_table, name)
              self.connection.add_column(votes_name_table, name, type)
            end
          end

        end

        if self.parent::VERSION::MAJOR < 4
          create_index votes_name_table, [:votable_id, :votable_type, :vote_ip]
          create_index votes_name_table, [:voter_id, :voter_type, :vote_ip]
        end

        create_index votes_name_table, [:voter_id, :voter_type, :vote_scope]
        create_index votes_name_table, [:votable_id, :votable_type, :vote_scope]
        create_index votes_name_table, [:voter_type, :vote_scope, :vote_ip]
        create_index votes_name_table, [:votable_type, :vote_scope, :vote_ip]
      end

      def drop_votable_table(options = {})
        votes_name_table = options[:votes] || :votes
        if self.connection.table_exists?(votes_name_table)
          self.connection.drop_table votes_name_table
        end
      end
    end
  end
end
