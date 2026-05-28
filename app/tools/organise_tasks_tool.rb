class OrganiseTasksTool < RubyLLM::Tool
  description "Organises the tasks of a schedule by locking fixed time tasks in place and intelligently slotting flexible tasks around them based on preferred times. Actually updates the database."

  param :schedule_id, desc: "The ID of the schedule to organise"

  def execute(schedule_id:)
    schedule = Schedule.find_by(id: schedule_id)
    return "Schedule not found." unless schedule

    tasks = schedule.tasks.to_a
    return "No tasks found for this schedule." if tasks.empty?

    fixed_tasks = tasks.select { |t| t.fixed_time.present? }.sort_by(&:fixed_time)
    flexible_tasks = tasks.select { |t| t.fixed_time.nil? }.sort_by { |t| t.preferred_time || Time.parse("23:59") }

    current_time = Time.parse("08:00")
    results = []

    # Report fixed tasks as-is
    fixed_tasks.each do |task|
      results << "#{task.category} locked at #{task.fixed_time.strftime("%H:%M")} (fixed)"
    end

    # Slot and SAVE flexible tasks
    flexible_tasks.each do |task|
      preferred = task.preferred_time
      slot = if preferred && !conflicts?(preferred, task.duration_min, fixed_tasks)
               preferred
             else
               find_next_slot(current_time, task.duration_min, fixed_tasks)
             end

      # Actually update the task in the database
      task.update!(preferred_time: slot)

      results << "#{task.category} scheduled at #{slot.strftime("%H:%M")} (#{task.duration_min} mins)"
      current_time = slot + task.duration_min * 60
    end

    "Schedule organised! Here's your updated day:\n" + results.join("\n")
  end

  private

  def conflicts?(time, duration_min, fixed_tasks)
    end_time = time + duration_min * 60
    fixed_tasks.any? do |t|
      t_end = t.fixed_time + t.duration_min * 60
      time < t_end && end_time > t.fixed_time
    end
  end

  def find_next_slot(from, duration_min, fixed_tasks)
    slot = from
    loop do
      return slot unless conflicts?(slot, duration_min, fixed_tasks)
      slot += 15 * 60
    end
  end
end
