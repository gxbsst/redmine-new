require File.dirname(__FILE__) + '/../test_helper'

class VoterTest < ActiveSupport::TestCase
  def votable
    votables(:votable)
  end

  def voter
    voters(:voter)
  end

  def votable_cache
    votable_caches(:votable_cache)
  end

  def votable_klass
    votable.class
  end

  def test_be_voted_on_after_a_voter_has_voted
    votable.vote_by :voter => voter
    assert voter.voted_on?(votable)
    assert voter.voted_for?(votable)
  end

  def test_not_be_voted_on_if_a_voter_has_not_voted
    assert !voter.voted_on?(votable)
  end

  def test_be_voted_on_after_a_voter_has_voted_under_scope
    votable.vote_by :voter => voter, :vote_scope => 'rank'
    assert voter.voted_on?(votable, :vote_scope => 'rank')
  end

  def test_not_be_voted_on_other_scope_after_a_voter_has_voted_under_one_scope
    votable.vote_by(:voter => voter, :vote_scope => 'rank')
    assert !voter.voted_on?(votable)
  end

  def test_be_voted_as_true_when_a_voter_has_voted_true
    votable.vote_by(:voter => voter)
    assert voter.voted_as_when_voted_on(votable)
    assert voter.voted_as_when_voted_for(votable)
  end

  def test_be_voted_as_true_when_a_voter_has_voted_true_under_scope
    votable.vote_by(:voter => voter, :vote_scope => 'rank')
    assert voter.voted_as_when_voted_for(votable, :vote_scope => 'rank')
  end

  def test_be_voted_as_false_when_a_voter_has_voted_false
    votable.vote_by(:voter => voter, :vote => false)
    assert !voter.voted_as_when_voted_for(votable)
  end

  def test_be_voted_as_false_when_a_voter_has_voted_false_under_scope
    votable.vote_by(:voter => voter, :vote => false, :vote_scope => 'rank')
    assert !voter.voted_as_when_voted_for(votable, :vote_scope => 'rank')
  end

  def test_be_voted_as_nil_when_a_voter_has_never_voted
    assert_nil voter.voted_as_when_voting_on(votable)
  end

  def test_be_voted_as_nil_when_a_voter_has_never_voted_under_the_scope
    votable.vote_by :voter => voter, :vote => false, :vote_scope => 'rank'
    assert_nil voter.voted_as_when_voting_on(votable)
  end

  def test_return_true_if_voter_has_voted_true
    votable.vote_by(:voter => voter)
    assert voter.voted_up_on?(votable)
  end

  def test_return_false_if_voter_has_not_voted_true
    votable.vote_by(:voter => voter, :vote => false)
    assert !voter.voted_up_on?(votable)
  end

  def test_return_true_if_the_voter_has_voted_false
    votable.vote_by(:voter => voter, :vote => false)
    assert voter.voted_down_on?(votable)
  end

  def test_return_false_if_the_voter_has_not_voted_false
    votable.vote_by(:voter => voter, :vote => true)
    assert !voter.voted_down_on?(votable)
  end

  def test_provide_reserve_functionality_voter_can_vote_on_votable
    voter.vote(:votable => votable, :vote => 'bad')
    assert !voter.voted_as_when_voting_on(votable)
  end

  def test_allow_the_voter_to_vote_up_a_model
    voter.vote_up_for(votable)
    assert_equal votable.get_up_votes.first.voter, voter
    assert_equal votable.votes_for.up.first.voter, voter
  end

  def test_allow_the_voter_to_vote_down_a_model
    voter.vote_down_for(votable)
    assert_equal votable.get_down_votes.first.voter, voter
    assert_equal votable.votes_for.down.first.voter, voter
  end

  def test_allow_the_voter_to_unvote_a_model
    voter.vote_up_for(votable)
    voter.unvote_for(votable)
    assert_equal votable.find_votes_for.size, 0
    assert_equal votable.votes_for.count, 0
  end

  def test_get_all_of_the_voters_votes
    voter.vote_up_for(votable)
    assert_equal voter.find_votes.size, 1
    assert_equal voter.votes.up.count, 1
  end

  def test_get_all_of_the_voters_up_votes
    voter.vote_up_for(votable)
    assert_equal voter.find_up_votes.size, 1
    assert_equal voter.votes.up.count, 1
  end

  def test_get_all_of_the_voters_down_votes
    voter.vote_down_for(votable)
    assert_equal voter.find_down_votes.size, 1
    assert_equal voter.votes.down.count, 1
  end

  def test_get_all_of_the_votes_otes_for_a_class
    votable.vote_by(:voter => voter)
    votables(:votable2).vote_by(:voter => voter, :vote => false)
    assert_equal voter.find_votes_for_class(votable_klass).size, 2
    assert_equal voter.votes.for_type(votable_klass).count, 2
  end

  def test_get_all_of_the_voters_up_votes_for_a_class
    votable.vote_by(:voter => voter)
    votables(:votable2).vote_by(:voter => voter, :vote => false)
    assert_equal voter.find_up_votes_for_class(votable_klass).size, 1
    assert_equal voter.votes.up.for_type(votable_klass).count, 1
  end

  def test_get_all_of_the_voters_down_votes_for_a_class
    votable.vote_by(:voter => voter)
    votables(:votable2).vote_by( :voter => voter, :vote => false)
    assert_equal voter.find_down_votes_for_class(votable_klass).size, 1
    assert_equal voter.votes.down.for_type(votable_klass).count, 1
  end

  def test_be_contained_to_instances
    voter.vote(:votable => votable, :vote => false)
    voters(:voter2).vote(:votable => votable)

    assert !voter.voted_as_when_voting_on(votable)
  end

  # describe '#find_voted_items

  def test_returns_objects_that_a_user_has_upvoted_for
    votable.vote_by(:voter => voter)
    votables(:votable2).vote_by(:voter => voters(:voter2))
    assert voter.find_voted_items.include? votable
    assert_equal voter.find_voted_items.size, 1
  end

  def test_returns_objects_that_a_user_has_upvoted_for_using_scope
    votable.vote_by(:voter => voter, :vote_scope => 'rank')
    votables(:votable2).vote_by(:voter => voters(:voter2), :vote_scope => 'rank')
    assert voter.find_voted_items(:vote_scope => 'rank').include? votable
    assert_equal voter.find_voted_items(:vote_scope => 'rank').size, 1
  end

  def test_returns_objects_that_a_user_has_downvoted_for
    votable.vote_down(voter)
    votables(:votable2).vote_down(voters(:voter2))
    assert voter.find_voted_items.include? votable
    assert_equal voter.find_voted_items.size, 1
  end

  def test_returns_objects_that_a_user_has_downvoted_for_using_scope
    votable.vote_down voter, :vote_scope => 'rank'
    votables(:votable2).vote_down(voters(:voter2), :vote_scope => 'rank')
    assert voter.find_voted_items(:vote_scope => 'rank').include? votable
    assert_equal voter.find_voted_items(:vote_scope => 'rank').size, 1
  end

  # describe '#find_up_voted_items
  def test_returns_objects_that_a_user_has_upvoted_for
    votable.vote_by(:voter => voter)
    votables(:votable2).vote_by :voter => voters(:voter2)
    assert voter.find_up_voted_items.include? votable
    assert_equal voter.find_up_voted_items.size, 1
    assert voter.find_liked_items.include? votable
    assert_equal voter.find_liked_items.size, 1
  end

  def test_returns_objects_that_a_user_has_upvoted_for_using_scope
    votable.vote_by(:voter => voter, :vote_scope => 'rank')
    votables(:votable2).vote_by(:voter => voters(:voter2), :vote_scope => 'rank')
    assert voter.find_up_voted_items(:vote_scope => 'rank').include? votable
    assert_equal voter.find_up_voted_items(:vote_scope => 'rank').size, 1
  end

  def test_does_not_return_objects_that_a_user_has_downvoted_for
    votable.vote_down voter
    assert_equal voter.find_up_voted_items.size, 0
  end

  def test_does_not_return_objects_that_a_user_has_downvoted_for_using_scope
    votable.vote_down voter, :vote_scope => 'rank'
    assert_equal voter.find_up_voted_items(:vote_scope => 'rank').size, 0
  end

  # describe '#find_down_voted_items

  def test_does_not_return_objects_that_a_user_has_upvoted_for
    votable.vote_by :voter => voter
    assert_equal voter.find_down_voted_items.size, 0
  end

  def test_does_not_return_objects_that_a_user_has_upvoted_for_using_scope
    votable.vote_by :voter => voter, :vote_scope => 'rank'
    assert_equal voter.find_down_voted_items(:vote_scope => 'rank').size, 0
  end

  def test_returns_objects_that_a_user_has_downvoted_for
    votable.vote_down voter
    votables(:votable2).vote_down voters(:voter2)
    assert voter.find_down_voted_items.include? votable
    assert_equal voter.find_down_voted_items.size, 1
    assert voter.find_disliked_items.include? votable
    assert_equal voter.find_disliked_items.size, 1
  end

  def test_returns_objects_that_a_user_has_downvoted_for_using_scope
    votable.vote_down voter, :vote_scope => 'rank'
    votables(:votable2).vote_down voters(:voter2), :vote_scope => 'rank'
    assert voter.find_down_voted_items(:vote_scope => 'rank').include? votable
    assert_equal voter.find_down_voted_items(:vote_scope => 'rank').size, 1
  end

  # describe '#get_voted
  def get_voted
    voter.get_voted(votable.class)
  end

  def test_returns_objects_of_a_class_that_a_voter_has_voted_for
    votable.vote_by :voter => voter
    votables(:votable2).vote_down voter
    assert get_voted.include? votable
    assert get_voted.include? votables(:votable2)
    assert_equal get_voted.size, 2
  end

  def test_does_not_return_objects_of_a_class_that_a_voter_has_voted_for
    votable.vote_by :voter => voters(:voter2)
    votables(:votable2).vote_by :voter => voters(:voter2)
    assert_equal get_voted.size, 0
  end

  # describe '#get_up_voted

  def get_up_voted
    voter.get_up_voted(votable.class)
  end

  def test_returns_up_voted_items_that_a_voter_has_voted_for
    votable.vote_by :voter => voter
    assert get_up_voted.include? votable
    assert_equal get_up_voted.size, 1
  end

  def test_does_not_return_down_voted_items_a_voter_has_voted_for
    votable.vote_down voter
    assert_equal get_up_voted.size, 0
  end

  # describe '#get_down_voted
  def get_down_voted
    voter.get_down_voted(votable.class)
  end

  def test_does_not_return_up_voted_items_that_a_voter_has_voted_for
    votable.vote_by :voter => voter
    assert_equal get_down_voted.size, 0
  end

  def test_returns_down_voted_items_a_voter_has_voted_for
    votable.vote_down voter
    assert get_down_voted.include? votable
    assert_equal get_down_voted.size, 1
  end
end
