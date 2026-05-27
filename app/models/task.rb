class Task < ApplicationRecord
  belongs_to :schedule

  validates :title, presence: true
  validates :duration_min, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :schedule_id, presence: true

  # At least one time field must be present
  validate :at_least_one_time_present

  # Helper method: returns which type of task this is
  def time_type
    if fixed_time.present?
      'fixed_time'
    elsif preferred_time.present?
      'preferred_time'
    else
      nil
    end
  end

  # Helper method: returns the actual time to display
  def display_time
    fixed_time || preferred_time
  end

  # Helper method: returns badge text
  def time_badge
    fixed_time.present? ? 'FIXED' : 'PREFERRED'
  end

  private

  def at_least_one_time_present
    if fixed_time.blank? && preferred_time.blank?
      errors.add(:base, 'Task must have either a fixed time or preferred time')
    end
  end
end
