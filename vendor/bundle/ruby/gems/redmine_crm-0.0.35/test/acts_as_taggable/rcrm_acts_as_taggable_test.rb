require File.dirname(__FILE__) + '/../test_helper'

class RcrmActsAsTaggableTest < ActiveSupport::TestCase
  def test_available_tags
    assert_equivalent [tags(:feature), tags(:bug), tags(:error), tags(:question)], Issue.available_tags(Project.first)
    assert_equivalent [tags(:error), tags(:question)], Issue.available_tags(:project => Project.first, :limit => 2)
  end

  def test_find_related_tags_with
    assert_equivalent [tags(:feature), tags(:bug), tags(:question)], Issue.find_related_tags("error")
    assert_equivalent [tags(:feature), tags(:error), tags(:question)], Issue.find_related_tags(tags(:bug))
    assert_equivalent [tags(:error), tags(:question)], Issue.find_related_tags(["New feature", "bug"])
    assert_equivalent [tags(:feature), tags(:bug)], Issue.find_related_tags([tags(:error), tags(:question)])
  end

  def test_find_tagged_with_include_and_order
    assert_equal issues(:third_issue, :first_issue, :second_issue),  Issue.find_tagged_with("question", :order => "issues.description DESC", :include => :user).to_a
  end

  def test_find_related_tags_with_non_existent_tags
    assert_equal [], Issue.find_related_tags("ABCDEFG")
    assert_equal [], Issue.find_related_tags(['HIJKLM'])
  end

  def test_find_related_tags_with_nothing
    assert_equal [], Issue.find_related_tags("")
    assert_equal [], Issue.find_related_tags([])
  end

  def test_find_tagged_with
    assert_equivalent [issues(:first_issue), issues(:second_issue), issues(:third_issue)], Issue.find_tagged_with('"error"')
    assert_equal Issue.find_tagged_with('"error"'), Issue.find_tagged_with(['error'])
    assert_equal Issue.find_tagged_with('"error"'), Issue.find_tagged_with([tags(:error)])

    assert_equivalent [issues(:second_issue),], Issue.find_tagged_with('New feature')
    assert_equal Issue.find_tagged_with('New feature'), Issue.find_tagged_with(['New feature'])
    assert_equal Issue.find_tagged_with('New feature'), Issue.find_tagged_with([tags(:feature)])
  end

  def test_find_tagged_with_nothing
    assert_equal [], Issue.find_tagged_with("")
    assert_equal [], Issue.find_tagged_with([])
  end

  def test_find_tagged_with_nonexistant_tags
    assert_equal [], Issue.find_tagged_with('ABCDEFG')
    assert_equal [], Issue.find_tagged_with(['HIJKLM'])
    assert_equal [], Issue.find_tagged_with([RedmineCrm::ActsAsTaggable::Tag.new(:name => 'unsaved tag')])
  end

  def test_find_tagged_with_match_all
    assert_equivalent [issues(:second_issue)], Issue.find_tagged_with('error, "bug", "New feature", "question"', :match_all => true)
  end

  def test_find_tagged_with_match_all_and_include
    assert_equivalent [issues(:first_issue), issues(:second_issue), issues(:third_issue)], Issue.find_tagged_with(['error', 'question'], :match_all => true, :include => :tags)
  end

  def test_find_tagged_with_conditions
    assert_equal [], Issue.find_tagged_with('"error", bug', :conditions => '1=0')
  end

  def test_find_tagged_with_duplicates_options_hash
    options = { :conditions => '1=1' }.freeze
    assert_nothing_raised { Issue.find_tagged_with("error", options) }
  end

  def test_find_tagged_with_exclusions
    assert_equivalent [issues(:first_issue), issues(:third_issue)], Issue.find_tagged_with("bug", :exclude => true)
    assert_equivalent [issues(:first_issue), issues(:third_issue)], Issue.find_tagged_with("'bug', feature", :exclude => true)
  end

  def test_find_options_for_find_tagged_with_no_tags_returns_empty_hash
    assert_equal Hash.new, Issue.find_options_for_find_tagged_with("")
    assert_equal Hash.new, Issue.find_options_for_find_tagged_with([nil])
  end

  def test_find_options_for_find_tagged_with_leaves_arguments_unchanged
    original_tags = issues(:second_issue).tags.dup
    Issue.find_options_for_find_tagged_with(issues(:second_issue).tags)
    assert_equal original_tags, issues(:second_issue).tags
  end

  def test_find_options_for_find_tagged_with_respects_custom_table_name
    RedmineCrm::ActsAsTaggable::Tagging.table_name = "categorisations"
    RedmineCrm::ActsAsTaggable::Tag.table_name = "categories"

    options = Issue.find_options_for_find_tagged_with("Hello")

    assert_no_match(/ taggings /, options[:joins])
    assert_no_match(/ tags /, options[:joins])

    assert_match(/ categorisations /, options[:joins])
    assert_match(/ categories /, options[:joins])
  ensure
    RedmineCrm::ActsAsTaggable::Tagging.table_name = "taggings"
    RedmineCrm::ActsAsTaggable::Tag.table_name = "tags"
  end

  def test_include_tags_on_find_tagged_with
    assert_nothing_raised do
      Issue.find_tagged_with('error', :include => :tags)
      Issue.find_tagged_with("error", :include => { :taggings => :tag })
    end
  end

  def test_basic_tag_counts_on_class
    assert_tag_counts Issue.tag_counts, :error => 3, :feature => 1, :question => 3, :bug => 1
  end

  def test_tag_counts_on_class_with_date_conditions
    assert_tag_counts Issue.tag_counts(:start_at => Date.new(2015, 1, 1)), :error => 2, :feature => 1, :question => 3, :bug => 1
    assert_tag_counts Issue.tag_counts(:end_at => Date.new(2014, 12, 31)), :error => 1
    assert_tag_counts Issue.tag_counts(:start_at => Date.new(2015, 1, 31), :end_at => Date.new(2015, 3, 1)), :question => 1
  end

  def test_tag_counts_on_class_with_frequencies
    assert_tag_counts Issue.tag_counts(:at_least => 2), :question => 3, :error => 3
    assert_tag_counts Issue.tag_counts(:at_most => 2), :bug => 1, :feature => 1
  end

  def test_tag_counts_on_class_with_frequencies_and_conditions
    assert_tag_counts Issue.tag_counts(:at_least => 2, :conditions => '1=1'), :question => 3, :error => 3
  end

  def test_tag_counts_duplicates_options_hash
    options = { :at_least => 2, :conditions => '1=1' }.freeze
    assert_nothing_raised { Issue.tag_counts(options) }
  end

  def test_tag_counts_with_limit
    assert_equal 2, Issue.tag_counts(:limit => 2).to_a.size
    assert_equal 2, Issue.tag_counts(:at_least => 3, :limit => 2).to_a.size
  end

  def test_tag_counts_with_limit_and_order
    assert_equivalent RedmineCrm::ActsAsTaggable::Tag.where(:id => [tags(:error), tags(:question)]), Issue.tag_counts(:order => 'count desc', :limit => 2)
  end

  def test_tag_counts_on_association
    assert_tag_counts users(:jonathan).issues.tag_counts, :error => 2, :bug => 1, :question => 2, :feature => 1
    assert_tag_counts users(:sam).issues.tag_counts, :error => 1, :question => 1
  end

  def test_tag_counts_on_association_with_options
    assert_equal [], users(:jonathan).issues.tag_counts(:conditions => '1=0')
    assert_tag_counts users(:jonathan).issues.tag_counts(:at_most => 2), :bug => 1,
      :feature => 1, :error => 2, :question => 2
  end

  def test_tag_counts_on_model_instance
    assert_tag_counts issues(:third_issue).tag_counts, :error => 3, :question => 3
  end

  def test_tag_counts_on_model_instance_merges_conditions
    assert_tag_counts issues(:first_issue).tag_counts(:conditions => "tags.name = 'error'"), :error => 3
  end

  def test_tag_counts_on_model_instance_with_no_tags
    issue = Issue.create!(:description => "desc")

    assert_tag_counts issue.tag_counts, {}
  end

  def test_tag_counts_should_sanitize_scope_conditions
    Issue.send :where, { "tags.id = ?" => tags(:error).id } do
      assert_tag_counts Issue.tag_counts, :error => 3
    end
  end

  def test_tag_counts_respects_custom_table_names
    RedmineCrm::ActsAsTaggable::Tagging.table_name = "categorisations"
    RedmineCrm::ActsAsTaggable::Tag.table_name = "categories"

    options = Issue.find_options_for_tag_counts(:start_at => 2.weeks.ago, :end_at => Date.today)
    sql = options.values.join(' ')

    assert_no_match %r{taggings}, sql
    assert_no_match %r{tags}, sql

    assert_match /categorisations/, sql
    assert_match /categories/, sql
  ensure
    RedmineCrm::ActsAsTaggable::Tagging.table_name = "taggings"
    RedmineCrm::ActsAsTaggable::Tag.table_name = "tags"
  end

  def test_tag_list_reader
    assert_equivalent ["error", "question"], issues(:first_issue).tag_list
    assert_equivalent ["error", "New feature", "bug", "question"], issues(:second_issue).tag_list
  end

  def test_reassign_tag_list
    assert_equivalent ["error", "question"], issues(:first_issue).tag_list
    issues(:first_issue).taggings.reload

    # Only an update of the issues table should be executed, the other two queries are for savepoints
    # assert_queries 3 do
    #   issues(:first_issue).update_attributes!(:description => "new name", :tag_list => issues(:first_issue).tag_list.to_s)
    # end

    assert_equivalent ["error", "question"], issues(:first_issue).tag_list
  end

  def test_new_tags
    assert_equivalent ["error", "question"], issues(:first_issue).tag_list
    issues(:first_issue).update_attributes!(:tag_list => "#{issues(:first_issue).tag_list}, One, Two")
    assert_equivalent ["error", "question", "One", "Two"], issues(:first_issue).tag_list
  end

  def test_remove_tag
    assert_equivalent ["error", "question"], issues(:first_issue).tag_list
    issues(:first_issue).update_attributes!(:tag_list => "error")
    assert_equivalent ["error"], issues(:first_issue).tag_list
  end

  def test_remove_and_add_tag
    assert_equivalent ["error", "question"], issues(:first_issue).tag_list
    issues(:first_issue).update_attributes!(:tag_list => "question, Beautiful")
    assert_equivalent ["question", "Beautiful"], issues(:first_issue).tag_list
  end

  def test_tags_not_saved_if_validation_fails
    assert_equivalent ["error", "question"], issues(:first_issue).tag_list
    assert !issues(:first_issue).update_attributes(:tag_list => "One, Two", :description => "")
    assert_equivalent ["error", "question"], Issue.find(issues(:first_issue).id).tag_list
  end

  def test_tag_list_accessors_on_new_record
    p = Issue.new(:description => 'Test')

    assert p.tag_list.blank?
    p.tag_list = "One, Two"
    assert_equal "One, Two", p.tag_list.to_s
  end

  def test_clear_tag_list_with_nil
    p = issues(:second_issue)

    assert !p.tag_list.blank?
    assert p.update_attributes(:tag_list => nil)
    assert p.tag_list.blank?

    assert p.reload.tag_list.blank?
  end

  def test_clear_tag_list_with_string
    p = issues(:second_issue)

    assert !p.tag_list.blank?
    assert p.update_attributes(:tag_list => '  ')
    assert p.tag_list.blank?

    assert p.reload.tag_list.blank?
  end

  def test_tag_list_reset_on_reload
    p = issues(:second_issue)
    assert !p.tag_list.blank?
    p.tag_list = nil
    assert p.tag_list.blank?
    assert !p.reload.tag_list.blank?
  end

  def test_instance_tag_counts
    assert_tag_counts issues(:first_issue).tag_counts, :error => 3, :question => 3
  end

  def test_tag_list_populated_when_cache_nil
    assert_nil issues(:first_issue).cached_tag_list
    issues(:first_issue).save!
    assert_equal issues(:first_issue).tag_list.to_s, issues(:first_issue).cached_tag_list
  end

  def test_cached_tag_list_updated
    assert_nil issues(:first_issue).cached_tag_list
    issues(:first_issue).save!
    assert_equivalent ["question", "error"], RedmineCrm::ActsAsTaggable::TagList.from(issues(:first_issue).cached_tag_list)
    issues(:first_issue).update_attributes!(:tag_list => "None")

    assert_equal 'None', issues(:first_issue).cached_tag_list
    assert_equal 'None', issues(:first_issue).reload.cached_tag_list
  end

  def test_clearing_cached_tag_list
    # Generate the cached tag list
    issues(:first_issue).save!

    issues(:first_issue).update_attributes!(:tag_list => "")
    assert_equal "", issues(:first_issue).cached_tag_list
  end

  def test_find_tagged_with_using_sti
    special_issue = SpecialIssue.create!(:description => 'Test', :tag_list => 'Random')

    assert_equal [special_issue], SpecialIssue.find_tagged_with('Random')
    assert SpecialIssue.find_tagged_with('Random').include?(special_issue)
  end

  def test_case_insensitivity
    assert_difference "RedmineCrm::ActsAsTaggable::Tag.count", 1 do
      Issue.create!(:description => "Test", :tag_list => "one")
      Issue.create!(:description => "Test", :tag_list => "One")
    end
    assert_equal Issue.find_tagged_with("question"), Issue.find_tagged_with("question")
  end

  def test_tag_not_destroyed_when_unused
    issues(:first_issue).tag_list.add("Random")
    issues(:first_issue).save!

    assert_no_difference 'RedmineCrm::ActsAsTaggable::Tag.count' do
      issues(:first_issue).tag_list.remove("Random")
      issues(:first_issue).save!
    end
  end

  def test_tag_destroyed_when_unused
    RedmineCrm::ActsAsTaggable::Tag.destroy_unused = true

    issues(:first_issue).tag_list.add("Random")
    issues(:first_issue).save!

    assert_difference 'RedmineCrm::ActsAsTaggable::Tag.count', -1 do
      issues(:first_issue).tag_list.remove("Random")
      issues(:first_issue).save!
    end
  ensure
    RedmineCrm::ActsAsTaggable::Tag.destroy_unused = false
  end

  def test_quote_value
    assert_equal "'RedmineCrm::ActsAsTaggable::Tag'", Issue.send(:quote_value, RedmineCrm::ActsAsTaggable::Tag)
  end

  def test_tags_condition
    assert_equal "(tags_TABLE.name LIKE #{tags(:feature).id} OR tags_TABLE.name LIKE #{tags(:bug).id})",
                 Issue.send(:tags_condition, [tags(:feature), tags(:bug)], 'tags_TABLE')
  end

  def test_all_tags_list
    issues(:first_issue).tag_list.remove('error')
    issues(:first_issue).tag_list.add('new')
    issues(:first_issue).save!
    assert_equal %w(question new), issues(:first_issue).reload.all_tags_list
  end
end
