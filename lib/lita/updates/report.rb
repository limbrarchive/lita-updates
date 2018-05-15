class Lita::Updates::Report
  NOTHING = /^(none|nothing|nada)$/i

  def initialize(robot, data, user)
    @robot = robot
    @data  = data
    @user  = user
  end

  def call
    robot.send_message Lita::Source.new(user: user), text
  end

  private

  attr_reader :robot, :data, :user

  def answer(prompt, value)
    return "" if value.strip.empty? || value[NOTHING]

    "#{prompt}\n  #{value}"
  end

  def answers
    [
      answer("What have you just been working on?", yesterday),
      answer("What's next?", today),
      answer("What blockers are impeding your progress?", blockers)
    ]
  end

  def blockers
    data.read "blockers"
  end

  def target
    Lita::Room.find_by_name Lita.config.handlers.updates.target
  end

  def text
    <<-TEXT.strip
#{user.name} posted a status update:
#{answers.join("\n\n")}
    TEXT
  end

  def today
    data.read "today"
  end

  def yesterday
    data.read "yesterday"
  end
end
