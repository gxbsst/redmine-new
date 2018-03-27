require_dependency 'redmine_questions/hooks/views_layouts_hook'

# require_dependency 'redmine_questions/patches/boards_controller_patch'
require_dependency 'redmine_questions/patches/message_patch'
require_dependency 'redmine_questions/patches/user_patch'
require_dependency 'redmine_questions/patches/messages_controller_patch'
require_dependency 'acts_as_votable_vote_patch' if ActiveRecord::VERSION::MAJOR >= 4
