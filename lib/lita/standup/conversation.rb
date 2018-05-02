class Lita::Standup::Conversation
  STATES = %w[ idle yesterday today blockers done ]
  PROMPTS = {
    "yesterday" => "Hi there, it’s time for our standup meeting :smile:\nWhat have you been working on?",
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
