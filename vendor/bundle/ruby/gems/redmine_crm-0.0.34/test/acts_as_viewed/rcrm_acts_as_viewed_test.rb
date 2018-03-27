require File.dirname(__FILE__) + '/../test_helper'

class RcrmActsAsViewedTest < ActiveSupport::TestCase
  def user
    users(:jonathan)
  end

  def issue
    issues(:first_issue)
  end

  def test_zero_of_view_count
    assert_equal issue.view_count, '0(0)'
  end

  def test_can_view
    issue.view '127.0.0.1', user
    assert_equal issue.view_count, '1(1)'
    # second view change only total count
    issue.view '127.0.0.1', user
    assert_equal issue.view_count, '2(1)'
  end

  def test_viewed_by
    assert !issue.viewed_by?('127.0.0.1', user)
    issue.view '127.0.0.1', user
    assert issue.viewed_by?('127.0.0.1', user)
  end

  def test_twice_view
    issue.view '127.0.0.1', user
    issue.view '127.0.0.1', user
    assert_equal '2(1)', issue.view_count
  end

  def test_viewed?
    assert !issue.viewed?
    issue.view '127.0.0.1', user
    assert issue.viewed?
  end

  def test_find_viewed_by
    assert_equal [], Issue.find_viewed_by(user)
    issue.view '127.0.0.1', user
    assert_equal [issue], Issue.find_viewed_by(user)
  end
end
