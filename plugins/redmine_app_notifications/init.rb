Redmine::Plugin.register :redmine_app_notifications do
  name 'Redmine App Notifications plugin'
  author 'Michal Vanzura & renewed by Tigergm'
  description 'App notifications plugin provides simple in application notifications. It can replace default e-mail notifications.'
  version '1.0.4'
  url 'https://bitbucket.org/39648421/redmine_app_notifications'
  author_url 'https://bitbucket.org/39648421'

  menu :top_menu, :app_notifications, { :controller => 'app_notifications', :action => 'index' }, {
  	:caption => :notifications, 
  	:last => true, 
  	:if => Proc.new { User.current.app_notification },
    :html => {:id => 'notificationsLink'}
  }
  
  menu :top_menu, :app_notifications_count, { :controller => 'app_notifications', :action => 'index' }, {
    :caption => Proc.new { AppNotification.where(recipient_id: User.current.id, viewed: false).count.to_s }, 
    :last => true, 
    :if => Proc.new { User.current.app_notification && AppNotification.where(recipient_id: User.current.id, viewed: false).count > 0 },
    :html => {:id => 'notification_count'}
  }

  settings :default => {
      'issue_added' => 'on',
      'issue_updated' => 'on', 
      'issue_note_added' => 'on', 
      'issue_status_updated' => 'on', 
      'issue_assigned_to_updated' => 'on', 
      'issue_priority_updated' => 'on'
    }, :partial => 'settings/app_notifications_settings'
end

require_dependency 'app_notifications_hook_listener'
require_dependency 'app_notifications_account_patch'
require_dependency 'app_notifications_issues_patch'
require_dependency 'app_notifications_journals_patch'
