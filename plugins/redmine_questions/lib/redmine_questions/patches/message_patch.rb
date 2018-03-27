module RedmineQuestions
  module Patches
    module MessagePatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          rcrm_acts_as_taggable
          rcrm_acts_as_votable
          rcrm_acts_as_viewed

          safe_attributes 'tag_list',
            :if => lambda {|message, user|
              user.allowed_to?(:edit_messages_tags, message.project)
            }
        end

      end

      module InstanceMethods

        def to_param
          "#{id}-#{ActiveSupport::Inflector.transliterate(subject).parameterize}"
        end

        def like(user)
          liked_by(user)
        end

        def dislike(user)
          unvote(:voter => user)
        end

      end

    end
  end
end

unless Message.included_modules.include?(RedmineQuestions::Patches::MessagePatch)
  Message.send(:include, RedmineQuestions::Patches::MessagePatch)
end

