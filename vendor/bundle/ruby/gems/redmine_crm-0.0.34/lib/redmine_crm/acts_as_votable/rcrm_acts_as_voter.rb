module RedmineCrm
  module ActsAsVotable
    module Voter
      def voter?
        false
      end

      def rcrm_acts_as_voter(*args)
        require 'redmine_crm/acts_as_votable/voter'
        include RedmineCrm::ActsAsVotable::Voter

        class_eval do
          def self.voter?
            true
          end
        end
      end
    end
  end
end
