require File.dirname(__FILE__) + '/../test_helper'

module RedmineCrm
  module ActsAsTaggable
    class TagListTest < ActiveSupport::TestCase
      def setup
        @tag_list = TagList.new(%w(error bug))
      end

      def test_from
        assert_equal %w(one two three), TagList.from('one, two, two, three, three, three')
      end

      def test_add
        @tag_list.add(['new_tag'])
        assert_equal %w(error bug new_tag), @tag_list
      end

      def test_remove
        @tag_list.remove(['old_tag'])
        assert_equal %w(error bug), @tag_list
        @tag_list.remove(['error'])
        assert_equal %w(bug), @tag_list
      end

      def test_toggle
        @tag_list.toggle(['new_tag'])
        assert_equal %w(error bug new_tag), @tag_list
        @tag_list.toggle(['error'])
        assert_equal %w(bug new_tag), @tag_list
      end

      def test_to_s
        assert_equal 'error, bug', @tag_list.to_s
      end
    end
  end
end
