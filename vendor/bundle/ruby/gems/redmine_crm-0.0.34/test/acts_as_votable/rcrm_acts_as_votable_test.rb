require File.dirname(__FILE__) + '/../test_helper'

class RcrmActsAsVotableTest < ActiveSupport::TestCase
  def test_not_be_votable
    assert !NotVotable.votable?, false
  end

  def test_be_votable
    assert Votable.votable?, true
  end

  def test_behaves_like_votable_model
    assert Voter.create(:name => 'i can vote!')
    assert VotableCache.create(:name => 'voting model with cache')
    assert VotableVoter.create(:name => 'i can vote too!')
  end
end
