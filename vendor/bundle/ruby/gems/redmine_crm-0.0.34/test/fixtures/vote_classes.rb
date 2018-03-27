class Voter < ActiveRecord::Base
  rcrm_acts_as_voter
end

class NotVoter < ActiveRecord::Base

end

class Votable < ActiveRecord::Base
  rcrm_acts_as_votable
  validates_presence_of :name
end

class VotableVoter < ActiveRecord::Base
  rcrm_acts_as_votable
  rcrm_acts_as_voter
end

class StiVotable < ActiveRecord::Base
  rcrm_acts_as_votable
end

class ChildOfStiVotable < StiVotable
end

class StiNotVotable < ActiveRecord::Base
  validates_presence_of :name
end

class VotableChildOfStiNotVotable < StiNotVotable
  rcrm_acts_as_votable
end

class NotVotable < ActiveRecord::Base
end

class VotableCache < ActiveRecord::Base
  rcrm_acts_as_votable
  validates_presence_of :name
end

class ABoringClass
  def self.hw
    'hello world'
  end
end

# def clean_database
#   models = [ActsAsVotable::Vote, Voter, NotVoter, Votable, NotVotable, VotableCache]
#   models.each do |model|
#     ActiveRecord::Base.connection.execute "DELETE FROM #{model.table_name}"
#   end
# end
