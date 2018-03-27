require File.dirname(__FILE__) + '/../test_helper'

module RedmineCrm
  module ActsAsTaggable
    class TagTest < ActiveSupport::TestCase
      def test_find_or_create_with_like_by_name
        assert_no_difference 'RedmineCrm::ActsAsTaggable::Tag.count' do
          Tag.find_or_create_with_like_by_name('error')
        end

        assert_difference 'RedmineCrm::ActsAsTaggable::Tag.count', 1 do
          Tag.find_or_create_with_like_by_name('new_tag')
        end
      end

      def test_name_required
        t = Tag.create
        assert_match /blank/, t.errors[:name].to_s
      end

      def test_name_unique
        t = Tag.create!(:name => 'My tag')
        duplicate = t.dup
        assert !duplicate.save
        assert_match /not uniq/, duplicate.errors[:name].to_s
      end

      def test_taggings
        assert_equivalent [taggings(:tag_for_error), taggings(:tag_for_error1), taggings(:tag_for_error2)], tags(:error).taggings
        assert_equivalent [taggings(:tag_for_question1), taggings(:tag_for_question2), taggings(:tag_for_question3)], tags(:question).taggings
      end

      def test_to_s
        assert_equal tags(:error).name, tags(:error).to_s
      end

      def test_equality
        assert_equal tags(:error), tags(:error)
        assert_equal Tag.find(tags(:error).id), Tag.find(tags(:error).id)
        assert_equal Tag.new(:name => 'A'), Tag.new(:name => 'A')
        assert_not_equal Tag.new(:name => 'A'), Tag.new(:name => 'B')
      end

      def test_taggings_removed_when_tag_destroyed
        assert_difference("Tagging.count", -Tagging.where(:tag_id => tags(:error).id).count) do
          assert tags(:error).destroy
        end
      end

      def test_all_counts
        assert_tag_counts Tag.counts, :error => 3, :feature => 1, :bug => 1, :question => 3
      end

      def test_all_counts_with_string_conditions
        assert_tag_counts Tag.counts(:conditions => 'taggings.created_at >= \'2015-01-01\''),
          :question => 3, :error => 2, :feature => 1, :bug => 1
      end

      def test_all_counts_with_array_conditions
        assert_tag_counts Tag.counts(:conditions => ['taggings.created_at >= ?', '2015-01-01']),
          :question => 3, :error => 2, :feature => 1, :bug => 1
      end
    end
  end
end
