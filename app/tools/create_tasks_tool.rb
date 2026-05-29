# app/tools/Create_challenges_tool.rb
class CreateTasksTool < RubyLLM::Tool
  description "Creates tasks for the current user on a given schedule."
  param :title, desc: "title of the task"
  param :duration_min, desc: "the duration of the task"
  param :preferred_time, desc: "the time when the task starts"

  def initialize(schedule:)
    @schedule = schedule
  end

  def execute(duration_min:, preferred_time:, title:)
    task = Task.create!(
      category: "",
      duration_min: duration_min,
      fixed_time: nil,
      preferred_time: preferred_time,
      title: title,
      schedule: @schedule
    )
    {
      status: "created",
      task_id: task.id,
      duration_min: duration_min,
      preferred_time: preferred_time,
      title: title
    }
  rescue ActiveRecord::RecordNotFound
    { error: "Challenge not found" }
  rescue ActiveRecord::RecordInvalid => e
    { error: e.message }
  end
end
