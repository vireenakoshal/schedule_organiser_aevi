class SchedulesController < ApplicationController
  before_action :set_schedule, only: [:show, :edit, :update]
  before_action :authenticate_user!
  
  def index
    @schedules = current_user.schedules.order(date: :desc)
  end

  def new
    @schedule = Schedule.new
  end

  def create
    @schedule = Schedule.new(schedule_params)
    @schedule.user = current_user

    if @schedule.save
      redirect_to schedule_path(@schedule), notice: "Schedule created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @schedule loaded by before_action
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to schedule_path(@schedule), notice: "Schedule updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def show
    @tasks = @schedule.tasks.order(fixed_time: :asc)
    @messages = @schedule.messages.order(created_at: :asc)
    # @free_blocks = calculate_free_blocks(@tasks)
  end

  private

  def set_schedule
    @schedule = current_user.schedules.find(params[:id])
  end
  
  def schedule_params
    params.require(:schedule).permit(:date, :notes)
  end
end
