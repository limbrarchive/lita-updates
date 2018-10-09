class Lita::Updates::SlackReport < Lita::Updates::Report
  def call
    robot.chat_service.api.send(
      :call_api,
      "chat.postMessage",
      as_user:     false,
      username:    user.mention_name,
      channel:     target.id,
      text:        "#{user.name} posted a status update:",
      attachments: JSON.dump(attachments.collect(&:to_hash))
    )
  end

  private

  def answer(prompt, value, colour)
    return nil if value.nil? || value.strip.empty? || value[NOTHING]

    Lita::Adapters::Slack::Attachment.new value,
      :title => prompt, :color => colour
  end

  def attachments
    [
      answer("What have you just been working on?", yesterday, "good"),
      answer("What’s next?", today, "warning"),
      answer("What blockers are impeding your progress?", blockers, "danger")
    ].compact
  end
end
