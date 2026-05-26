class Schedule < ApplicationRecord
  belongs_to :user
  has_many :tasks
  has_many :messages
end
