class SchedulesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_schedule, only: [:show]

  # def index
  #   @schedules = current_user.schedules.order(date: :desc)
  # end

  def show
    @tasks = @schedule.tasks.order(fixed_time: :asc)
    @messages = @schedule.messages.order(created_at: :asc)
    # @free_blocks = calculate_free_blocks(@tasks)
  end

  # def new
  #   @schedule = Schedule.new
  # end

  # def create
  #   @schedule = current_user.schedules.build(schedule_params)
  #   if @schedule.save
  #     redirect_to @schedule, notice: "Schedule created!"
  #   else
  #     render :new, status: :unprocessable_entity
  #   end
  # end

  # def destroy
  #   @schedule.destroy
  #   redirect_to schedules_path, notice: "Schedule deleted."
  # end

  private

  def set_schedule
    @schedule = current_user.schedules.find(params[:id])
  end

  # def schedule_params
  #   params.require(:schedule).permit(:date)
  # end

  # def calculate_free_blocks(tasks)

  #   day_start = @schedule.day_start
  #   day_end   = @schedule.day_end
  # # rest of the method stays the same, just replace DAY_START/DAY_END
  # # with day_start/day_end
  #   free_blocks = []
  #   # Use fixed_time if present, otherwise fall back to preferred_time
  #   scheduled = tasks
  #     .select { |t| t.fixed_time.present? || t.preferred_time.present? }
  #     .map do |t|
  #       start_time = t.fixed_time || t.preferred_time
  #       end_time   = start_time + (t.duration_min * 60)
  #       { start: start_time, end: end_time, task: t }
  #     end
  #     .sort_by { |t| t[:start] }

  #   # Check gap between day start and first task
  #   current_time = DAY_START

  #   scheduled.each do |block|
  #     if block[:start] > current_time
  #       free_blocks << { from: current_time, to: block[:start] }
  #     end
  #     # Move pointer forward if this task ends later than current position
  #     current_time = block[:end] if block[:end] > current_time
  #   end

  #   # Check gap between last task and end of day
  #   if current_time < DAY_END
  #     free_blocks << { from: current_time, to: DAY_END }
  #   end
  #   free_blocks
  # end
end
