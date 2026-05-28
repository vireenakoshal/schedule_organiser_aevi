class Schedule < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy
  has_many :messages, dependent: :destroy

  validates :user_id, presence: true
  validates :date, presence: true
end
