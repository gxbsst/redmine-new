require 'redmine_crm/helpers/vote_helper'

module RedmineCrm
  module ActsAsVotable
    class Vote < ActiveRecord::Base
      include Helpers::Words

      if defined?(ProtectedAttributes) || ::ActiveRecord::VERSION::MAJOR < 4
        attr_accessible :votable_id, :votable_type,
          :voter_id, :voter_type,
          :votable, :voter,
          :vote_flag, :vote_scope,
          :vote_ip
      end

      belongs_to :votable, :polymorphic => true
      belongs_to :voter, :polymorphic => true

      scope :up, lambda { where(:vote_flag => true) }
      scope :down, lambda { where(:vote_flag => false) }
      scope :for_type, lambda { |klass| where(:votable_type => klass.to_s) }
      scope :by_type,  lambda { |klass| where(:voter_type => klass.to_s) }

      validates_presence_of :votable_id
      validates_presence_of :voter_id
    end
  end
end
