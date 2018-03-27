require File.dirname(__FILE__) + '/../liquid_helper'
include LiquidHelperMethods

module RedmineCrm
  class ProjectsDropTest < ActiveSupport::TestCase
    def setup
      @project = Project.first
      @user = User.first
      @liquid_render = LiquidRender.new('user' => Liquid::UserDrop.new(@user),
                                        'project' => Liquid::ProjectDrop.new(@project),
                                        'projects' => Liquid::ProjectsDrop.new(Project.all))
    end

    def test_projects_all
      projects_text = @liquid_render.render('{% for project in projects.all %} {{project.identifier }} {% endfor %}')
      Project.all.map(&:identifier).each do |identifier|
        assert_match identifier, projects_text
      end
    end

    def test_projects_active
      projects_text = @liquid_render.render('{% for project in projects.active %} {{project.identifier }} {% endfor %}')
      Project.where(:status => 1).map(&:identifier).each do |identifier|
        assert_match identifier, projects_text
      end
    end

    def test_projects_size
      assert_equal '2', @liquid_render.render('{{ projects.size }}')
    end

    def test_project_issues
      issues_text = @liquid_render.render('{% for issue in project.issues %} {{issue.subject }} {% endfor %}')
      Project.first.issues.each do |issue|
        assert_match issue.subject, issues_text
      end
    end

    def test_project_delegated
      assert_equal [@project.id, @project.identifier, @project.description].join('|'),
                   @liquid_render.render('{{ project.id }}|{{ project.identifier }}|{{ project.description }}')
    end
  end
end
