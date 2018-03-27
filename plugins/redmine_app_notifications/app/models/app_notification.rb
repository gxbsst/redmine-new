include GravatarHelper::PublicMethods
include ERB::Util

class AppNotification < ActiveRecord::Base
	belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
	belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
	belongs_to :issue
	belongs_to :journal

	def deliver
    channel = "/notifications/private/#{recipient.id}"
    message = { count: AppNotification.where(recipient_id: recipient.id, viewed: false).count, message: message_text, id: id, avatar: gravatar_url(author.mail, { :default => Setting.gravatar_default })}
    PrivatePub.publish_to channel, message
	end

	def is_edited?
		journal.present?
	end

	def message_text
		if is_edited?
			I18n.t(:text_issue_updated, :id => "##{issue.id}", :author => author)
		else
			I18n.t(:text_issue_added, :id => "##{issue.id}", :author => author)
		end
	end
end
