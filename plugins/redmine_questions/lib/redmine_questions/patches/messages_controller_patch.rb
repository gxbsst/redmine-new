module RedmineQuestions
  module Patches

    module MessagesControllerPatch

      module InstanceMethods

        def view_message
          @message.view(request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip || request.remote_addr, User.current.logged? ? User.current : nil) unless @message.author == User.current
        end

      end

      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          after_filter :view_message, :only => :show
        end
      end

    end

  end
end

unless MessagesController.included_modules.include?(RedmineQuestions::Patches::MessagesControllerPatch)
  MessagesController.send(:include, RedmineQuestions::Patches::MessagesControllerPatch)
end
