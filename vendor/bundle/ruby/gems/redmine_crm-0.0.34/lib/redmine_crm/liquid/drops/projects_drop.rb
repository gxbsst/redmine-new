module RedmineCrm
  module Liquid
    class ProjectsDrop < ::Liquid::Drop

      def self.default_drop
        self.new Project.visible.order(:name)
      end

      def initialize(projects)
        @projects = projects
      end

      def before_method(identifier)
        project = @projects.where(:identifier => identifier).first || Project.new
        ProjectDrop.new project
      end

      def all
        @all ||= @projects.map do |project|
          ProjectDrop.new project
        end
      end

      def active
        @active ||= @projects.select(&:active?).map do |project|
          ProjectDrop.new project
        end
      end

      def each(&block)
        all.each(&block)
      end

      def size
        @projects.size
      end
    end

    class ProjectDrop < ::Liquid::Drop
      include ActionView::Helpers::UrlHelper

      delegate :id,
               :identifier,
               :name,
               :is_public,
               :description,
               :visible?,
               :active?,
               :archived?,
               :short_description,
               :start_date,
               :due_date,
               :overdue?,
               :completed_percent,
               :to => :@project

      def initialize(project)
        @project = project
      end

      def link
        link_to @project.name, self.url
      end

      def url
        Rails.application.routes.url_helpers.project_path(@project)
      end

      def issues
        @issues ||= IssuesDrop.new @project.issues.visible
      end

      def users
        @users ||= UsersDrop.new @project.users
      end

      def subprojects
        @subprojects ||= ProjectsDrop.new @project.children
      end

      def custom_field_values
        @project.custom_field_values
      end         
    end
  end
end
