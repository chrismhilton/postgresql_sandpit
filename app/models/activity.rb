class Activity < ActiveRecord::Base
  belongs_to :user
  has_many :activity_notes
end
