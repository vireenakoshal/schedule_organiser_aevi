class Task < ApplicationRecord
  belongs_to :schedule

  validates :category, presence: true
  validates :duration_min, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :schedule_id, presence: true
  validate :at_least_one_time_present
  validate :no_fixed_time_clash, if: -> { fixed_time.present? }

  # Helper method: returns which type of task this is
  def time_type
    fixed_time.present? ? "fixed_time" : "preferred_time"
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

  def no_fixed_time_clash
  clashing = schedule.tasks
    .where.not(id: id)
    .select { |t| t.fixed_time.present? }
    .any? do |t|
      t_end  = t.fixed_time + t.duration_min * 60
      my_end = fixed_time + duration_min * 60
      fixed_time < t_end && my_end > t.fixed_time
    end

  if clashing
    errors.add(:base, "You have an activity clash! Cannot save task. Change your time preference for a smoother day.")
  end
  end
end
