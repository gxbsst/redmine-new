require File.dirname(__FILE__) + '/../test_helper'

class VotableTest < ActiveSupport::TestCase
  def votable
    votables(:votable)
  end

  def test_vote_without_voter
    assert !votables(:votable).vote_by
  end

  def test_have_vote_when_saved
    votable.vote_by(:voter => voters(:voter), :vote => "yes")
    assert_equal votable.votes_for.size, 1
  end

  def test_have_vote_when_saved_by_id
    votable.vote_by(:voter => voters(:voter), :vote => "yes", :vote_ip => '127.0.0.1')
    assert_equal votable.votes_for.size, 1
    assert_equal votable.votes_for.last.vote_ip, '127.0.0.1'
  end

  def test_voted_twice_by_one_ip
    votable.vote_by(:voter => voters(:voter), :vote => "yes", :vote_ip => '127.0.0.1', :vote_by_ip => true)
    votable.vote_by(:voter => voters(:voter), :vote => "no", :vote_ip => '127.0.0.1', :vote_by_ip => true)
    assert_equal votable.votes_for.size, 1
  end

  def test_voted_twice_by_one_ip_with_duplicate_params
    votable.vote_by(:voter => voters(:voter), :vote => "yes", :vote_ip => '127.0.0.1', :vote_by_ip => true)
    votable.vote_by(:voter => voters(:voter), :vote => "no", :vote_ip => '127.0.0.1', :vote_by_ip => true, :duplicate => true)
    assert_equal votable.votes_for.size, 2
  end

  def test_one_scoped_vote_by_ip_when_using_scope_by_same_person
    votable.vote_by(:voter => voters(:voter), :vote => 'yes', :vote_scope => 'rank', :vote_ip => '127.0.0.1', :vote_by_ip => true)
    votable.vote_by(:voter => voters(:voter), :vote => 'yes', :vote_scope => 'rank', :vote_ip => '127.0.0.1', :vote_by_ip => true)
    assert_equal votable.find_votes_for(:vote_scope => 'rank').size, 1
  end

  def test_two_votes_for_when_voting_on_two_diff_scopes
    votable.vote_by(:voter => voters(:voter), :vote => 'yes', :vote_scope => 'weekly_rank', :vote_ip => '127.0.0.1', :vote_by_ip => true)
    votable.vote_by(:voter => voters(:voter), :vote => 'yes', :vote_scope => 'monthly_rank', :vote_ip => '127.0.0.1', :vote_by_ip => true)
    assert_equal votable.votes_for.size, 2
  end

  def test_voted_twice_by_same_person
    votable.vote_by(:voter => voters(:voter), :vote => "yes")
    votable.vote_by(:voter => voters(:voter), :vote => "no")
    assert_equal votable.votes_for.size, 1
  end

  def test_voted_twice_by_same_person_with_duplicate_params
    votable.vote_by(:voter => voters(:voter), :vote => "yes")
    votable.vote_by(:voter => voters(:voter), :vote => "no", :duplicate => true)
    assert_equal votable.votes_for.size, 2
  end

  def test_one_scoped_vote
    votable.vote_by(:voter => voters(:voter), :vote => 'yes', :vote_scope => 'rank')
    assert_equal votable.find_votes_for(:vote_scope => 'rank').size, 1
  end

  def test_one_scoped_vote_when_using_scope_by_same_person
    votable.vote_by(:voter => voters(:voter), :vote => 'yes', :vote_scope => 'rank')
    votable.vote_by(:voter => voters(:voter), :vote => 'yes', :vote_scope => 'rank')
    assert_equal votable.find_votes_for(:vote_scope => 'rank').size, 1
  end

  def test_two_votes_for_when_voting_on_two_diff_scopes
    votable.vote_by(:voter => voters(:voter), :vote => 'yes', :vote_scope => 'weekly_rank')
    votable.vote_by(:voter => voters(:voter), :vote => 'yes', :vote_scope => 'monthly_rank')
    assert_equal votable.votes_for.size, 2
  end

  def test_called_with_vote_up
    votables(:votable).vote_up voters(:voter)
    assert_equal votables(:votable).get_up_votes.first.voter, voters(:voter)
  end

  def test_called_with_vote_down
    votables(:votable).vote_down voters(:voter)
    assert_equal votables(:votable).get_down_votes.first.voter, voters(:voter)
  end

  def test_have_two_votes_when_voted_two_different_people
    votable.vote_by(:voter => voters(:voter))
    votable.vote_by(:voter => voters(:voter2))
    assert_equal votable.votes_for.size, 2
  end

  def test_one_true_vote
    votable.vote_by(:voter => voters(:voter))
    votable.vote_by(:voter => voters(:voter2), :vote => "dislike")
    assert_equal votable.get_up_votes.size, 1
  end

  def test_two_false_votes
    votable.vote_by(:voter => voters(:voter), :vote => 'no')
    votable.vote_by(:voter => voters(:voter2), :vote => "dislike")
    assert_equal votable.get_down_votes.size, 2
  end

  def test_have_been_voted_on_by_voter2
    votable.vote_by(:voter => voters(:voter2), :vote => true)
    assert_equal votable.find_votes_for.first.voter.id, voters(:voter2).id
  end

  def test_count_the_vote_as_registered_if_this_the_voters_first_vote
    votable.vote_by(:voter => voters(:voter))
    assert votable.vote_registered?
  end

  def test_not_count_the_vote_as_being_registered_if_that_voter_has_alredy_voted_and_voted_has_not_chanded
    votable.vote_by(:voter => voters(:voter), :vote => true)
    votable.vote_by(:voter => voters(:voter), :vote => 'yes')
    assert !votable.vote_registered?
  end

  def test_count_the_vote_as_registered_if_the_voter_has_voted_and_the_flag_has_changed
    votable.vote_by(:voter => voters(:voter), :vote => true)
    votable.vote_by(:voter => voters(:voter), :vote => 'dislike')
    assert votable.vote_registered?
  end

  def test_count_the_vote_as_registered_if_the_voter_has_voted_and_vote_weight_has_changed
    votable.vote_by(:voter => voters(:voter), :vote => true, :vote_weight => 1)
    votable.vote_by(:voter => voters(:voter), :vote => true, :vote_weight => 2)
    assert votable.vote_registered?
  end

  def test_voted_on_by_voter
    votable.vote_by(:voter => voters(:voter))
    assert votable.voted_on_by?(voters(:voter))
  end

  def test_unvoted
    votable.liked_by(voters(:voter))
    votable.unliked_by(voters(:voter))
    assert !votable.voted_on_by?(voters(:voter))
  end

  def test_unvoted_positive_vote
    votable.vote_by(:voter => voters(:voter))
    votable.unvote(:voter => voters(:voter))
    assert_equal votable.find_votes_for.count, 0
  end

  def test_set_the_votable_to_unregistered_after_unvoting
    votable.vote_by(:voter => voters(:voter))
    votable.unvote(:voter => voters(:voter))
    assert !votable.vote_registered?
  end

  def test_unvote_a_negative_vote
    votable.vote_by(:voter => voters(:voter), :vote => "no")
    votable.unvote(:voter => voters(:voter))
    assert_equal votable.find_votes_for.count, 0
  end

  def test_unvote_only_the_from_a_single_voter
    votable.vote_by(:voter => voters(:voter))
    votable.vote_by(:voter => voters(:voter2))
    votable.unvote(:voter => voters(:voter))
    assert_equal votable.find_votes_for.count, 1
  end

  def test_contained_to_instance
    votable2 = Votable.new(:name => "2nd votable")
    votable2.save

    votable.vote_by(:voter => voters(:voter), :vote => false)
    votable2.vote_by(:voter => voters(:voter), :vote => true)
    votable2.vote_by(:voter => voters(:voter), :vote => true)

    assert votable.vote_registered?
    assert !votable2.vote_registered?
  end

  def test_default_weight_if_not_specified
    votable.upvote_by(voters(:voter))
    assert_equal votable.find_votes_for.first.vote_weight, 1
  end

  # with cached votes_for

  def voter
    voters(:voter)
  end

  def votable_cache
    votable_caches(:votable_cache)
  end

  def test_not_update_cached_votes_for_if_there_are_no_colums
    votable.vote_by(:voter => voter)
  end

  def test_update_chaced_votes_for_if_there_is_a_total_column
    votable_cache.cached_votes_total = 50
    votable_cache.vote_by(voter: voter)
    assert_equal votable_cache.cached_votes_total, 1
  end

  def test_update_cached_total_votes_for_when_a_vote_up_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'true')
    votable_cache.unvote(:voter => voter)
    assert_equal votable_cache.cached_votes_total, 0
  end

  def test_update_cachded_score_votes_for_if_there_is_a_score_column
    votable_cache.cached_votes_score = 50
    votable_cache.vote_by(:voter => voter)
    assert_equal votable_cache.cached_votes_score, 1
    votable_cache.vote_by(:voter => voters(:voter2), :vote => 'false')
    assert_equal votable_cache.cached_votes_score, 0
    votable_cache.vote_by(:voter => voter, :vote => 'false')
    assert_equal votable_cache.cached_votes_score, -2
  end

  def test_update_cached_score_votef_for_when_a_vote_up_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'true')
    assert_equal votable_cache.cached_votes_score, 1
    votable_cache.unvote(:voter => voter)
    assert_equal votable_cache.cached_votes_score, 0
  end

  def test_update_cached_score_votef_for_when_a_vote_down_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'false')
    assert_equal votable_cache.cached_votes_score, -1
    votable_cache.unvote(:voter => voter)
    assert_equal votable_cache.cached_votes_score, 0
  end

  def test_updata_cached_weighted_total_if_there_is_a_weighted_total_column
    votable_cache.cached_weighted_total = 50
    votable_cache.vote_by(:voter => voter)
    assert_equal votable_cache.cached_weighted_total, 1
    votable_cache.vote_by(:voter => voters(:voter2), :vote => 'false')
    assert_equal votable_cache.cached_weighted_total, 2
  end

  def test_update_cached_weighted_total_votes_for_when_a_vote_up_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'true', :vote_weight => 3)
    assert_equal votable_cache.cached_weighted_total, 3
    votable_cache.unvote(:voter => voter)
    assert_equal votable_cache.cached_weighted_total, 0
  end

  def test_update_cached_weighted_total_votes_for_when_a_vote_down_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'false', :vote_weight => 4)
    assert_equal votable_cache.cached_weighted_total, 4
    votable_cache.unvote(:voter => voter)
    assert_equal votable_cache.cached_weighted_total, 0
  end

  def test_update_cached_weighted_score_if_there_is_a_weighted_score_column
    votable_cache.cached_weighted_score = 50
    votable_cache.vote_by(:voter => voter, :vote_weight => 3)
    assert_equal votable_cache.cached_weighted_score, 3
    votable_cache.vote_by(:voter => voters(:voter2), :vote => 'false', :vote_weight => 5)
    assert_equal votable_cache.cached_weighted_score, -2
    # voter changes her vote from 3 to 5
    votable_cache.vote_by(:voter => voter, :vote_weight => 5)
    assert_equal votable_cache.cached_weighted_score, 0
    votable_cache.vote_by :voter => voters(:voter3), :vote_weight => 4
    assert_equal votable_cache.cached_weighted_score, 4
  end

  def test_update_cached_weighted_score_votes_for_when_a_vote_up_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'true', :vote_weight => 3)
    assert_equal votable_cache.cached_weighted_score, 3
    votable_cache.unvote :voter => voter
    assert_equal votable_cache.cached_weighted_score, 0
  end

  def test_update_cached_weighted_score_votes_for_when_a_vote_down_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'false', :vote_weight => 4)
    assert_equal votable_cache.cached_weighted_score, -4
    votable_cache.unvote :voter => voter
    assert_equal votable_cache.cached_weighted_score, 0
  end

  def test_update_cached_weighted_average_if_there_is_a_weighted_average_column
    votable_cache.cached_weighted_average = 50.0
    votable_cache.vote_by(:voter => voter, :vote => 'true', :vote_weight => 5)
    assert_equal votable_cache.cached_weighted_average, 5.0
    votable_cache.vote_by(:voter => voters(:voter2), :vote => 'true', :vote_weight => 3)
    assert_equal votable_cache.cached_weighted_average, 4.0
    # voter changes her vote from 5 to 4
    votable_cache.vote_by(:voter => voter, :vote => 'true', :vote_weight => 4)
    assert_equal votable_cache.cached_weighted_average, 3.5
    votable_cache.vote_by(:voter => voters(:voter3), :vote => 'true', :vote_weight => 5)
    assert_equal votable_cache.cached_weighted_average, 4.0
  end

  def test_update_cached_weighted_average_votes_for_when_a_vote_up_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'true', :vote_weight => 5)
    votable_cache.vote_by(:voter => voters(:voter2), :vote => 'true', :vote_weight => 3)
    assert_equal votable_cache.cached_weighted_average, 4
    votable_cache.unvote :voter => voter
    assert_equal votable_cache.cached_weighted_average, 3
  end

  def test_update_cached_up_votes_for_if_there_is_an_up_vote_column
    votable_cache.cached_votes_up = 50
    votable_cache.vote_by(:voter => voter)
    votable_cache.vote_by(:voter => voter)
    assert_equal votable_cache.cached_votes_up, 1
  end

  def test_update_cached_down_votes_for_if_there_is_a_down_vote_column
    votable_cache.cached_votes_down = 50
    votable_cache.vote_by(:voter => voter, :vote => 'false')
    assert_equal votable_cache.cached_votes_down, 1
  end

  def test_update_cached_up_votes_for_when_a_vote_up_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'true')
    votable_cache.unvote(:voter => voter)
    assert_equal votable_cache.cached_votes_up, 0
  end

  def test_update_cached_down_votes_for_when_a_vote_down_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'false')
    votable_cache.unvote(:voter => voter)
    assert_equal votable_cache.cached_votes_down, 0
  end

  def test_select_from_cached_total_votes_for_if_there_a_total_column
    votable_cache.vote_by(:voter => voter)
    votable_cache.cached_votes_total = 50
    assert_equal votable_cache.count_votes_total, 50
  end

  def test_select_from_cached_up_votes_for_if_there_is_an_up_vote_column
    votable_cache.vote_by(:voter => voter)
    votable_cache.cached_votes_up = 50
    assert_equal votable_cache.count_votes_up, 50
  end

  def test_select_from_cached_down_votes_for_if_there_is_a_down_vote_column
    votable_cache.vote_by(:voter => voter, :vote => 'false')
    votable_cache.cached_votes_down = 50
    assert_equal votable_cache.count_votes_down, 50
  end

  def test_select_from_cached_weighted_total_if_there_is_a_weighted_total_column
    votable_cache.vote_by(:voter => voter, :vote => 'false')
    votable_cache.cached_weighted_total = 50
    assert_equal votable_cache.weighted_total, 50
  end

  def test_select_from_cached_weighted_score_if_there_is_a_weighted_score_column
    votable_cache.vote_by( :voter => voter, :vote => 'false')
    votable_cache.cached_weighted_score = 50
    assert_equal votable_cache.weighted_score, 50
  end

  def test_select_from_cached_weighted_average_if_there_is_a_weighted_average_column
    votable_cache.vote_by( :voter => voter, :vote => 'false')
    votable_cache.cached_weighted_average = 50
    assert_equal votable_cache.weighted_average, 50
  end

  def test_update_cached_total_votes_for_when_voting_under_an_scope
    votable_cache.vote_by( :voter => voter, :vote => 'true', :vote_scope => 'rank')
    assert_equal votable_cache.cached_votes_total, 1
  end

  def test_update_cached_up_votes_for_when_voting_under_an_scope
    votable_cache.vote_by( :voter => voter, :vote => 'true', :vote_scope => 'rank')
    assert_equal votable_cache.cached_votes_up, 1
  end

  def test_update_cached_total_votes_for_when_a_scoped_vote_down_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'true', :vote_scope => 'rank')
    votable_cache.unvote( :voter => voter, :vote_scope => 'rank')
    assert_equal votable_cache.cached_votes_total, 0
  end

  def test_update_cached_up_votes_for_when_a_scoped_vote_down_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'true', :vote_scope => 'rank')
    votable_cache.unvote(:voter => voter, :vote_scope => 'rank')
    assert_equal votable_cache.cached_votes_up, 0
  end

  def test_update_cached_down_votes_for_when_downvoting_under_a_scope
    votable_cache.vote_by(:voter => voter, :vote => 'false', :vote_scope => 'rank')
    assert_equal votable_cache.cached_votes_down, 1
  end

  def test_update_cached_down_votes_for_when_a_scoped_vote_down_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'false', :vote_scope => 'rank')
    votable_cache.unvote(:voter => voter, :vote_scope => 'rank')
    assert_equal votable_cache.cached_votes_down, 0
  end

  # describe "with scoped cached votes_for

  def test_update_cached_total_votes_for_if_there_is_a_total_column
    votable_cache.cached_scoped_test_votes_total = 50
    votable_cache.vote_by(:voter => voter, :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_total, 1
  end

  def test_update_cached_total_votes_for_when_a_vote_up_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'true', :vote_scope => "test")
    votable_cache.unvote(:voter => voter, :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_total, 0
  end

  def test_update_cached_total_votes_for_when_a_vote_down_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'false', :vote_scope => "test")
    votable_cache.unvote(:voter => voter, :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_total, 0
  end

  def test_update_cached_score_votes_for_if_there_is_a_score_column
    votable_cache.cached_scoped_test_votes_score = 50
    votable_cache.vote_by(:voter => voter, :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_score, 1
    votable_cache.vote_by(:voter => voters(:voter2), :vote => 'false', :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_score, 0
    votable_cache.vote_by(:voter => voter, :vote => 'false', :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_score, -2
  end

  def test_update_cached_score_votes_for_when_a_vote_up_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'true', :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_score, 1
    votable_cache.unvote(:voter => voter, :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_score, 0
  end

  def test_update_cached_score_votes_for_when_a_vote_down_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'false', :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_score, -1
    votable_cache.unvote(:voter => voter, :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_score, 0
  end

  def test_update_cached_up_votes_for_if_there_is_an_up_vote_column
    votable_cache.cached_scoped_test_votes_up = 50
    votable_cache.vote_by(:voter => voter, :vote_scope => "test")
    votable_cache.vote_by(:voter => voter, :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_up, 1
  end

  def test_update_cached_down_votes_for_if_there_is_a_down_vote_column
    votable_cache.cached_scoped_test_votes_down = 50
    votable_cache.vote_by(:voter => voter, :vote => 'false', :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_down, 1
  end

  def test_update_cached_up_votes_for_when_a_vote_up_is_removed
    votable_cache.vote_by :voter => voter, :vote => 'true', :vote_scope => "test"
    votable_cache.unvote :voter => voter, :vote_scope => "test"
    assert_equal votable_cache.cached_scoped_test_votes_up, 0
  end

  def test_update_cached_down_votes_for_when_a_vote_down_is_removed
    votable_cache.vote_by(:voter => voter, :vote => 'false', :vote_scope => "test")
    votable_cache.unvote(:voter => voter, :vote_scope => "test")
    assert_equal votable_cache.cached_scoped_test_votes_down, 0
  end

  def test_select_from_cached_total_votes_for_if_there_a_total_column
    votable_cache.vote_by(:voter => voter, :vote_scope => "test")
    votable_cache.cached_scoped_test_votes_total = 50
    assert_equal votable_cache.count_votes_total(false, "test"), 50
  end

  def test_select_from_cached_up_votes_for_if_there_is_an_up_vote_column
    votable_cache.vote_by(:voter => voter, :vote_scope => "test")
    votable_cache.cached_scoped_test_votes_up = 50
    assert_equal votable_cache.count_votes_up(false, "test"), 50
  end

  def test_select_from_cached_down_votes_for_if_there_is_a_down_vote_column
    votable_cache.vote_by(:voter => voter, :vote => 'false', :vote_scope => "test")
    votable_cache.cached_scoped_test_votes_down = 50
    assert_equal votable_cache.count_votes_down(false, "test"), 50
  end

  # describe "sti models

  def test_be_able_to_vote_on_a_votable_child_of_a_non_votable_sti_model
    votable = VotableChildOfStiNotVotable.create(:name => 'sti child')

    votable.vote_by(:voter => voter, :vote => 'yes')
    assert_equal votable.votes_for.size, 1
  end

  def test_not_be_able_to_vote_on_a_parent_non_votable
    assert !StiNotVotable.votable?
  end

  def test_be_able_to_vote_on_a_child_when_its_parent_is_votable
    votable = ChildOfStiVotable.create(:name => 'sti child')

    votable.vote_by(:voter => voter, :vote => 'yes')
    assert_equal votable.votes_for.size, 1
  end


end
