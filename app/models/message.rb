class Message < ApplicationRecord
  belongs_to :schedule

  SYSTEM_PROMPT = "you are an assistant that looks at the available time blocks and suggests what activities can be done in the designated time block. suggest activities based on what the user likes, always start with wholesome activities like walk with a friend, go for a relaxing walk by the beach etc "

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @schedule = @chat.schedule

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

  if @message.save
    # ...
  end
end
end
