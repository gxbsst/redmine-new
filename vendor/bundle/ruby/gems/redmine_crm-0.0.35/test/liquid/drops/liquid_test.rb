# require File.dirname(__FILE__) + '/../liquid_helper'

# module RedmineCrm
#   class LiquidTest < ActiveSupport::TestCase

#     def test_user_drop
#       user = User.first
#       assert_match user.name, render("{{ user.name }}")
#     end

#     def test_users_drop
#       users_name = User.all.map(&:name)
#       rendered_text = render("{% for user in users %} {{user.name }} {% endfor %}")
#       users_name.each do |name|
#         assert_match name, rendered_text
#       end
#     end

#     def test_issue_drop
#       assert_match Issue.first.description, render("{{ issue.description }}")
#     end

#     def test_default_filter
#       user = User.first
#       user.name = nil
#       user.save
#       assert_match 'user', render("{{ user.name | default: 'user' }}")
#     end

#     private

#     def render(content)
#       assigns = {}
#       assigns['now'] = Time.now
#       assigns['today'] = Date.today.strftime(date_format)
#       assigns['user'] = Liquid::UserDrop.new(User.first)
#       assigns['users'] = Liquid::UsersDrop.new(User.all)
#       assigns['issue'] = Liquid::IssueDrop.new(Issue.first)

#       registers = {}
#       begin
#         ::Liquid::Template.parse(content).render(::Liquid::Context.new({}, assigns, registers)).html_safe
#       rescue => e
#         e.message
#       end
#     end

#     def date_format
#       '%d.%m.%Y'
#     end
#   end
# end
