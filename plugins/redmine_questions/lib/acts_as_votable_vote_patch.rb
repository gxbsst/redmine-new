module RedmineQuestions
  module Patches
    module ActsAsVotableVotePatch
      def self.included(base) # :nodoc:
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          attr_accessible :votable, :voter, :vote_scope
        end
      end
    end
  end
end

unless RedmineCrm::ActsAsVotable::Vote.included_modules.include?(RedmineQuestions::Patches::ActsAsVotableVotePatch)
  RedmineCrm::ActsAsVotable::Vote.send(:include, RedmineQuestions::Patches::ActsAsVotableVotePatch)
end