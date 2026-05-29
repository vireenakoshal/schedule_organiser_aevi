class TasksController < ApplicationController
  before_action :set_schedule, only: %i[create create_with_ai destroy edit update]
  before_action :set_task, only: %i[destroy edit update]

  def create
    @task = @schedule.tasks.build(task_params)

    if @task.preferred_time.present? && @task.fixed_time.blank?
      free_slot = @schedule.next_available_slot(@task.preferred_time, @task.duration_min)
      @task.preferred_time = free_slot
    end

    if @task.save
      redirect_to @schedule, notice: "Task added successfully."
    else
      redirect_to @schedule, alert: @task.errors.full_messages.first
    end
  end

  def create_with_ai
    # Prevent duplicate within the same 10 seconds
    recent = @schedule.tasks
      .where(created_at: 10.seconds.ago..Time.now)
      .exists?

    if recent
      return redirect_to @schedule, alert: "Task was just created — please wait a moment before adding another."
    end

    task_summary = @schedule.tasks.map do |t|
      time = t.fixed_time&.strftime("%H:%M") || t.preferred_time&.strftime("%H:%M") || "flexible"
      "- #{t.category} at #{time} for #{t.duration_min} mins"
    end.join("\n")

    existing_categories = @schedule.tasks.pluck(:category).join(", ")

    system_prompt = <<~PROMPT
      You are a personal scheduling assistant with great taste. Add ONE specific activity to the user's schedule.

      The user is based in Barcelona, Spain.

      Tasks already on the schedule:
      #{task_summary.presence || "No tasks yet"}

      Tasks that already exist (DO NOT recreate these):
      #{existing_categories.presence || "None"}

      Rules:
      - Task names must be SPECIFIC and VIVID — include a location, object, or sensory detail
      - GOOD examples:
          "Run along Barceloneta beach"
          "Read in Parc de la Ciutadella"
          "Sketch the view from your rooftop"
          "Walk through El Born and grab a coffee"
          "20 min stretch with lo-fi music"
          "Journal your week over a glass of wine"
      - BAD examples: "Fun Activity", "Relaxation", "Creative Task", "Fun Activity at X"
      - Do NOT repeat or rephrase any task already on the schedule
      - Choose a preferred_time that does not clash with existing tasks
      - Duration between 20 and 60 minutes
      - Vary the type — active, creative, social, or restful

      Call CreateTasksTool immediately. Do not explain or ask questions. Just act.
      Call CreateTasksTool ONCE and only once. After the tool returns a result, stop immediately.
      Do not call the tool again under any circumstances.
    PROMPT

    @ruby_llm_chat = RubyLLM.chat
    @ruby_llm_chat.with_tool(CreateTasksTool.new(schedule: @schedule))
    @ruby_llm_chat.with_instructions(system_prompt).ask("Add a fun task to my schedule")

    redirect_to @schedule, notice: "AI task created!"
  rescue => e
    redirect_to @schedule, alert: "Could not create task: #{e.message}"
  end

  def destroy
    @task.destroy
    redirect_to @schedule, notice: "Task deleted successfully."
  end

  def edit
  end

  def update
    if params[:completed].present?
      @task.update(completed: params[:completed] == 'true')
      redirect_to @schedule, notice: "Task updated successfully."
    end
    
    permitted = task_params

    if permitted[:preferred_time].present? && permitted[:fixed_time].blank?
      duration  = permitted[:duration_min] || @task.duration_min
      free_slot = @schedule.next_available_slot(
        Time.parse(permitted[:preferred_time].to_s),
        duration.to_i
      )
      permitted[:preferred_time] = free_slot
    end

    if @task.update(permitted)
      redirect_to @schedule, notice: "Task updated successfully."
    else
      redirect_to @schedule, alert: @task.errors.full_messages.join(", ")
    end
  end

  private

  def set_schedule
    @schedule = Schedule.find(params[:schedule_id])
  end

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    permitted = params.require(:task).permit(
      :category,
      :duration_min,
      :time_type,
      :fixed_time,
      :preferred_time
    )

    if permitted[:time_type] == "fixed_time"
      permitted[:preferred_time] = nil
    elsif permitted[:time_type] == "preferred_time"
      permitted[:fixed_time] = nil
    end

    permitted.except(:time_type)
  end
end
