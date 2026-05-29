class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_schedule, only: :create

  def create
    task_summary = @schedule.tasks.map do |t|
      time = t.fixed_time&.strftime("%H:%M") || t.preferred_time&.strftime("%H:%M") || "flexible"
      "- #{t.category} (#{t.duration_min} mins at #{time})"
    end.join("\n")

    system_prompt = <<~PROMPT
      You are Aevi, a friendly and energetic personal scheduling assistant.
      The user is currently viewing schedule ID: #{@schedule.id} for #{@schedule.date.strftime("%A, %d %B %Y")}.
       The user has the following tasks scheduled:
       #{task_summary}
      You have access to the OrganiseTasksTool.
      When the user says ANYTHING like "shuffle", "organise", "optimize", "sort" or "rearrange" their tasks or schedule,
      you MUST call OrganiseTasksTool immediately with schedule_id: #{@schedule.id}.
      Do NOT ask the user for the schedule ID — you already have it.
      Your job is to suggest fun, practical activities to fill their free time blocks.
      Rules:
      - Only suggest activities that realistically fit within the available time
      - Start by suggesting 2-3 varied options (something active, creative, mindful)
      - Adapt suggestions based on user preferences
      - Be concise, warm and encouraging
      - Once agreed, end your message with:
      CONFIRMED_ACTIVITY: {"category": "Activity name", "duration_min": 30, "preferred_time": "14:00"}
    PROMPT

    @message = Message.new(message_params)
    @message.schedule = @schedule
    @message.role = "user"

    if @message.save
      @user_message = @message
      @ruby_llm_chat = RubyLLM.chat(model: "gpt-4o")
      @ruby_llm_chat.with_tool(OrganiseTasksTool)
      build_conversation_history
      response = @ruby_llm_chat.with_instructions(system_prompt).ask(@message.content)
      @assistant_message = Message.create!(role: "assistant", content: response.content, schedule: @schedule)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @schedule }
      end
    else
      redirect_to @schedule, alert: "Message could not be saved."
    end
  end

  private

  def build_conversation_history
    @schedule.messages.order(:created_at).each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def set_schedule
    @schedule = current_user.schedules.find(params[:schedule_id])
  end
end
