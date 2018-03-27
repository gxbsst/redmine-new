require File.dirname(__FILE__) + '/test_helper'

# module RedmineCrm
  class TagsHelperTest < ActiveSupport::TestCase
    include RedmineCrm::TagsHelper
    
    def test_tag_cloud
      cloud_elements = []
      
      tag_cloud Issue.tag_counts, %w(css1 css2 css3 css4) do |tag, css_class|
        cloud_elements << [tag, css_class]
      end
      assert cloud_elements.include?([tags(:error), "css4"])
      assert cloud_elements.include?([tags(:question), "css4"])
      assert cloud_elements.include?([tags(:bug), "css2"])
      assert cloud_elements.include?([tags(:feature), "css2"])
      assert_equal 4, cloud_elements.size
    end
    
    # def test_tag_cloud_when_no_tags
    #   cloud_elements = []
    #   tag_cloud SpecialIssue.tag_counts, %w(css1) do |tag, css_class|
    #     # assert false, "tag_cloud should not yield"
    #     cloud_elements << [tag, css_class]
    #   end
    #   assert_equal 0, cloud_elements.size
    # end
  end
# end