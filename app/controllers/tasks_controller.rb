class TasksController < ApplicationController
  before_action :set_schedule, only: [:create, :destroy, :edit, :update]
  before_action :set_task, only: [:destroy, :edit, :update]

  def create
    @task = @schedule.tasks.new(task_params)

    if @task.save
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
