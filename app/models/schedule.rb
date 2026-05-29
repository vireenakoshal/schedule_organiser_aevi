class Schedule < ApplicationRecord
  belongs_to :user
  has_many :tasks, dependent: :destroy
  has_many :messages, dependent: :destroy

  validates :user_id, presence: true
  validates :date, presence: true
  # Returns the next available time slot that doesn't overlap existing tasks
  def next_available_slot(start_time, duration_min)
  slot = start_time

  loop do
    return slot if slot_free?(slot, duration_min)
    slot += 15 * 60
  end
end

  def day_vibe
  return :empty if tasks.empty?

  fixed_count     = tasks.count { |t| t.fixed_time.present? }
  preferred_count = tasks.count { |t| t.preferred_time.present? }
  total           = tasks.count
  avg_duration    = tasks.sum(&:duration_min).to_f / total

  if fixed_count >= total * 0.6 || avg_duration >= 60
    :productive
  else
    :relaxed
  end
  end

  def vibe_message
    case day_vibe
    when :productive
    "🚀 Big day ahead — let's get it!"
    when :relaxed
    "🌿 A well-balanced, restorative day awaits"
    when :empty
    nil
    end
  end

  def vibe_color
    case day_vibe
    when :productive then "#C1713A"
    when :relaxed    then "#6A9E7F"
    when :empty      then nil
    end
  end

  private

  def slot_free?(time, duration_min)
  end_time = time + duration_min * 60

  tasks.none? do |t|
    task_start = t.fixed_time || t.preferred_time
    next false unless task_start

    task_end = task_start + t.duration_min * 60
    time < task_end && end_time > task_start
  end
  end
end
