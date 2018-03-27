class Issue < ActiveRecord::Base
  rcrm_acts_as_taggable
  rcrm_acts_as_viewed

  belongs_to :project
  belongs_to :user
  belongs_to :author, :class_name => 'User'
  validates_presence_of :description

  scope :visible, lambda { where('1=1') }

  def save_without_validation
    save
  end

  def self.quote_value(value)
    connection.quote(value)
  end
end

class SpecialIssue < Issue
end
