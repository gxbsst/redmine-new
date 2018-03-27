require 'minitest/autorun'
require 'byebug'
# require 'test/unit'

begin
  require File.dirname(__FILE__) + '/../../../../config/environment'
rescue LoadError
  require 'rubygems'
  gem 'activerecord'
  gem 'actionpack'
  require 'active_record'
end
require "redmine_crm"
require "active_record/fixtures"

require File.dirname(__FILE__) + '/../lib/redmine_crm/acts_as_taggable/tag'
require File.dirname(__FILE__) + '/../lib/redmine_crm/acts_as_taggable/tag_list'
require File.dirname(__FILE__) + '/../lib/redmine_crm/acts_as_taggable/tagging'
require File.dirname(__FILE__) + '/../lib/redmine_crm/acts_as_taggable/rcrm_acts_as_taggable'
require File.dirname(__FILE__) + '/../lib/redmine_crm/helpers/tags_helper'
require File.dirname(__FILE__) + '/../lib/redmine_crm/acts_as_votable/rcrm_acts_as_votable'
require File.dirname(__FILE__) + '/../lib/redmine_crm/acts_as_votable/rcrm_acts_as_voter'

# require_dependency File.dirname(__FILE__) + '/../lib/redmine_crm/tags_helper'

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[ENV['DB'] || 'sqlite3'])

load(File.dirname(__FILE__) + '/schema.rb')
load(File.dirname(__FILE__) + '/fixtures/user.rb')
load(File.dirname(__FILE__) + '/fixtures/issue.rb')
load(File.dirname(__FILE__) + '/fixtures/vote_classes.rb')
load(File.dirname(__FILE__) + '/fixtures/news.rb')
load(File.dirname(__FILE__) + '/fixtures/project.rb')

# Dir["/fixtures/*.rb"].each{|file| load file}

class ActiveSupport::TestCase #:nodoc:
  include ActiveRecord::TestFixtures

  self.fixture_path = File.dirname(__FILE__) + '/fixtures/'

  self.use_transactional_tests = true
  self.use_instantiated_fixtures = false
  set_fixture_class :tags => RedmineCrm::ActsAsTaggable::Tag
  set_fixture_class :taggings => RedmineCrm::ActsAsTaggable::Tagging

  set_fixture_class :votable_caches => VotableCache
  fixtures :all

  def assert_equivalent(expected, actual, message = nil)
    if expected.first.is_a?(ActiveRecord::Base)
      assert_equal expected.sort_by(&:id), actual.sort_by(&:id), message
    else
      assert_equal expected.sort, actual.sort, message
    end
  end

  def assert_tag_counts(tags, expected_values)
    # Map the tag fixture names to real tag names
    expected_values = expected_values.inject({}) do |hash, (tag, count)|
      hash[tags(tag).name] = count
      hash
    end

    tags.each do |tag|
      value = expected_values.delete(tag.name)

      assert_not_nil value, "Expected count for #{tag.name} was not provided"
      assert_equal value, tag.count, "Expected value of #{value} for #{tag.name}, but was #{tag.count}"
    end

    unless expected_values.empty?
      assert false, "The following tag counts were not present: #{expected_values.inspect}"
    end
  end

  # def assert_queries(num = 1)
  #   $query_count = 0
  #   yield
  # ensure
  #   assert_equal num, $query_count, "#{$query_count} instead of #{num} queries were executed."
  # end

  # def assert_queries(num = 1, options = {})
  #   ignore_none = options.fetch(:ignore_none) { num == :any }
  #   SQLCounter.clear_log
  #   yield
  # ensure
  #   the_log = ignore_none ? SQLCounter.log_all : SQLCounter.log
  #   if num == :any
  #     assert_operator the_log.size, :>=, 1, "1 or more queries expected, but none were executed."
  #   else
  #     mesg = "#{the_log.size} instead of #{num} queries were executed.#{the_log.size == 0 ? '' : "\nQueries:\n#{the_log.join("\n")}"}"
  #     assert_equal num, the_log.size, mesg
  #   end
  # end

  def assert_no_queries(&block)
    assert_queries(0, &block)
  end

  # From Rails trunk
  def assert_difference(expressions, difference = 1, message = nil, &block)
    expression_evaluations = [expressions].flatten.collect{ |expression| lambda { eval(expression, block.binding) } }

    original_values = expression_evaluations.inject([]) { |memo, expression| memo << expression.call }
    yield
    expression_evaluations.each_with_index do |expression, i|
      assert_equal original_values[i] + difference, expression.call, message
    end
  end

  def assert_no_difference(expressions, message = nil, &block)
    assert_difference expressions, 0, message, &block
  end
end
