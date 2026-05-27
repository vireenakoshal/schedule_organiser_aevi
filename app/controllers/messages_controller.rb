class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_schedule, only: :create

  SYSTEM_PROMPT = "You are Aevi, a friendly and energetic personal scheduling assistant.
  The user has the following tasks scheduled for #{@schedule.date.strftime("%A, %d %B %Y")}:
  #{task_summary}
  Your job is to suggest fun, practical activities to fill their free time blocks.
  Rules:
  - Only suggest activities that realistically fit within the available time (e.g. don't suggest a 2 hour hike for a 20 minute block)
  - Start by suggesting 2-3 varied options (e.g. something active, something creative, something mindful)
  - If the user says they prefer a certain type of activity (e.g. "something chill" or "I want to move my body"), adapt all future suggestions to match that preference
  - Be concise, warm and encouraging — no long paragraphs
  - Once the user agrees on an activity, confirm it clearly and end your message with this exact format so the app can save it:
  CONFIRMED_ACTIVITY: {"category": "Activity name", "duration_min": 30, "preferred_time": "14:00"}"
  
  def create
    @message = Message.new(message_params)
    @message.schedule = @schedule
    @message.role = "user"
    if @message.save

    ruby_llm_chat = RubyLLM.chat
    response = ruby_llm_chat.with_instructions(SYSTEM_PROMPT).ask(@message.content)
    Message.create(role: "assistant", content: response.content, schedule: @schedule)
    redirect_to @schedule
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def set_schedule
    @schedule = current_user.schedules.find(params[:schedule_id])
  end
end
