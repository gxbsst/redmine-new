module RedmineCrm
  module ExternalAssetsHelper
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::JavaScriptHelper

    def select2_assets
      return if @select2_tag_included
      @select2_tag_included = true
      javascript_include_tag('select2', :plugin => 'redmine_crm') + stylesheet_link_tag('select2', :plugin => 'redmine_crm')
    end

    def chartjs_assets
      return if @chartjs_tag_included
      @chartjs_tag_included = true
      javascript_include_tag('Chart.bundle.min', :plugin => 'redmine_crm')
    end
  end
end
