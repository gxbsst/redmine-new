require File.dirname(__FILE__) + '/../test_helper'

module RedmineCrm
  module ActsAsTaggable
    class TaggingTest < ActiveSupport::TestCase
      def test_tag
        assert_equal tags(:error), taggings(:tag_for_error).tag
      end

      def test_taggable
        assert_equal issues(:first_issue), taggings(:tag_for_error).taggable
      end
    end
  end
end
