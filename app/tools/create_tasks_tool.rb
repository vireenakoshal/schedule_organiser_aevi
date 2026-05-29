class CreateTasksTool < RubyLLM::Tool
  description "Creates ONE task for the current user on a given schedule. Only call this tool once per request."

  param :category, desc: "The specific name of the task e.g. Run along Barceloneta beach"
  param :duration_min, desc: "Duration of the task in minutes e.g. 30"
  param :preferred_time, desc: "Preferred start time in HH:MM format e.g. 09:00"

  def initialize(schedule:)
    @schedule = schedule
    @already_created = false
  end

  def execute(category:, duration_min:, preferred_time:)
    # Hard stop if tool has already been called once
    if @already_created
      return { error: "Task already created. Stop." }
    end

    # Check if a task with this name already exists
    existing = @schedule.tasks.find { |t| t.category.downcase == category.downcase }
    return { error: "Task '#{category}' already exists on this schedule." } if existing

    parsed_time = Time.parse(preferred_time)

    # Find next free slot with no overlaps
    free_slot = @schedule.next_available_slot(parsed_time, duration_min.to_i)

    task = Task.new(
      category:       category,
      duration_min:   duration_min.to_i,
      fixed_time:     nil,
      preferred_time: free_slot,
      schedule:       @schedule
    )

    unless task.save
      return { error: task.errors.full_messages.join(", ") }
    end

    @already_created = true

    {
      status:         "created",
      task_id:        task.id,
      category:       category,
      duration_min:   duration_min,
      preferred_time: free_slot.strftime("%H:%M")
    }
  rescue ArgumentError => e
    { error: "Invalid time format: #{e.message}" }
  end
end
