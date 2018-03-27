require File.dirname(__FILE__) + '/test_helper'

class VoteHelperTest < ActiveSupport::TestCase
  def vote
    RedmineCrm::ActsAsVotable::Vote.new
  end

  def test_know_that_like_is_a_true_vote
    assert vote.votable_words.that_mean_true.include? "like"
  end

  def test_know_that_bad_is_a_false_vote
    assert vote.votable_words.that_mean_false.include? "bad"
  end

  def test_be_a_vote_for_true_when_word_is_good
    assert vote.votable_words.meaning_of('good')
  end

  def test_be_a_vote_for_false_when_word_is_down
    assert !vote.votable_words.meaning_of('down')
  end

  def test_be_a_vote_for_true_when_the_word_is_unknown
    assert vote.votable_words.meaning_of('lsdhklkadhfs')
  end

end