class Schedule < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy
  has_many :messages, dependent: :destroy
end
