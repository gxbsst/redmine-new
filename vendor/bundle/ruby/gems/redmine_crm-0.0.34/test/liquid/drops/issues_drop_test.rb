require File.dirname(__FILE__) + '/../liquid_helper'
include LiquidHelperMethods

module RedmineCrm
  class IssuesDropTest < ActiveSupport::TestCase
    def setup
      @issue = Issue.first
      @user = User.first
      @liquid_render = LiquidRender.new('user' => Liquid::UserDrop.new(@user),
                                        'issue' => Liquid::IssueDrop.new(@issue),
                                        'issues' => Liquid::IssuesDrop.new(Issue.all))
    end

    def test_issues_all
      issues_text = @liquid_render.render('{% for issue in issues.all %} {{issue.subject }} {% endfor %}')
      Issue.all.map(&:subject).each do |subject|
        assert_match subject, issues_text
      end
    end

    def test_issues_size
      assert_equal '4', @liquid_render.render('{{ issues.size }}')
    end

    def test_issue_author
      assert_equal @user.name, @liquid_render.render('{{ issue.author.name }}')
    end

    def test_issue_delegated
      assert_equal [@issue.id, @issue.subject, @issue.description].join('|'),
                   @liquid_render.render('{{ issue.id }}|{{ issue.subject }}|{{ issue.description }}')
    end
  end
end
