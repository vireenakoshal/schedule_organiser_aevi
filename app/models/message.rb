class Message < ApplicationRecord
   belongs_to :schedule

  MAX_USER_MESSAGES = 10

  validates :content, presence: true
  validates :role, presence: true
  validate :user_message_limit, if: -> { role == "user" }

  private

  def user_message_limit
    if schedule.messages.where(role: "user").count >= MAX_USER_MESSAGES
      errors.add(:content, "You can only send #{MAX_USER_MESSAGES} messages per schedule")
    end
  end
end
