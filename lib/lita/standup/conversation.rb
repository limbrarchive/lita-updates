class Lita::Standup::Conversation
  INTRODUCTION = <<-TXT
Hi there, it’s time for our standup meeting :smile:
There are just three questions (to skip a question, just reply with "None". To skip the standup, reply with "Cancel").
  TXT
  STATES = %w[ idle yesterday today blockers done ]
  PROMPTS = {
    "yesterday" => "#{INTRODUCTION}\nWhat have you been working on?",
    "today"     => "What are you working on next?",
    "blockers"  => "What blockers are impeding your progress?",
    "done"      => "Thanks! I’ll let everyone know what you’ve been up to."
  }

  def initialize(robot, redis, user, message = nil)
    @robot   = robot
    @data    = Lita::Standup::Data.new redis, user
    @user    = user
    @message = message

    self.state = "idle" if state.nil? || state.empty?
  end

  def call
    return if message && state == "idle"
    if message && message.body.downcase == "cancel"
      say "This standup has been cancelled. To start again, just say `standup`."
      self.state = "idle"
      return
    end

    data.write state, message.body unless state == "idle" || message.nil?

    self.state = next_state
    say PROMPTS[state]

    if state == "done"
      report
      self.state = "idle"
    end
  end

  private

  attr_reader :robot, :data, :user, :message

  def next_state
    STATES[STATES.index(state) + 1] || "idle"
  end

  def state
    data.read("state") || "idle"
  end

  def state=(value)
    data.write "state", value
  end

  def say(text)
    return if text.nil? || text.empty?

    robot.send_message(Lita::Source.new(user: @user), text)
  end


  def report
    reporter.new(robot, data, user).call
  end

  def reporter
    case Lita.config.robot.adapter
    when :slack
      Lita::Standup::SlackReport
    else
      Lita::Standup::Report
    end
  end
end
