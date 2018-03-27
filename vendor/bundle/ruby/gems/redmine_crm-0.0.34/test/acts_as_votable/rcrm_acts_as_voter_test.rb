require File.dirname(__FILE__) + '/../test_helper'

class RcrmActsAsVoterTest < ActiveSupport::TestCase
  def test_not_be_votable
    assert !NotVoter.voter?, false
  end

  def test_be_voter
    assert Voter.voter?, true
    assert VotableVoter.voter?, true
  end
end
