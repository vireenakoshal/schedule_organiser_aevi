class TasksController < ApplicationController
  before_action :set_schedule, only: %i[create create_with_ai destroy edit update]
  before_action :set_task, only: %i[destroy edit update]

  SYSTEM_PROMPT = <<~PROMPT
    You are a smart daily schedule task.

    I am a lazy person who needs help managing my tasks for the day.

    Create a task to fill my day.

    You have access to tools:
    - Creates tasks for the current user on a given schedule, but create only one task.
  PROMPT

  def create
    @task = @schedule.tasks.new(task_params)

    if @task.save
      redirect_to @schedule, notice: "Task added successfully."
    else
      redirect_to @schedule, alert: "Error adding task."
    end
  end

  def create_with_ai
    # @task = @schedule.tasks.new(task_params)
    @ruby_llm_chat = RubyLLM.chat

    @ruby_llm_chat.with_tool(CreateTasksTool.new(schedule: @schedule))

    response = @ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask("Can you schedule creative and interesting task for me?")

    if response.class == RubyLLM::Message
      redirect_to @schedule, notice: "Task added successfully."
    else
      redirect_to @schedule, alert: "Error adding task."
    end
  end

  def destroy
    @task.destroy
    redirect_to @schedule, notice: "Task deleted successfully."
  end

  def edit
    # @task loaded by before_action
  end

  def update
    if @task.update(task_params)
      redirect_to @schedule, notice: "Task updated successfully."
    else
      redirect_to @schedule, alert: "Error updating task."
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
    permitted_params = params.require(:task).permit(:title, :duration_min, :time_type, :display_time)

    # Map time_type and display_time to fixed_time or preferred_time
    if permitted_params[:time_type].present? && permitted_params[:display_time].present?
      if permitted_params[:time_type] == 'fixed_time'
        permitted_params[:fixed_time] = permitted_params[:display_time]
        permitted_params[:preferred_time] = nil
      elsif permitted_params[:time_type] == 'preferred_time'
        permitted_params[:preferred_time] = permitted_params[:display_time]
        permitted_params[:fixed_time] = nil
      end
    end

    # Remove the form field names since we've mapped them
    permitted_params.delete(:time_type)
    permitted_params.delete(:display_time)

    permitted_params
  end
end
