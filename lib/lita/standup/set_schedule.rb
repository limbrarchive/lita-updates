class Lita::Standup::SetSchedule
  def self.call(robot, redis, user, message)
    new(robot, redis, user, message).call
  end

  def initialize(robot, redis, user, message)
    @robot   = robot
    @redis   = redis
    @user    = user
    @message = message
  end

  def call
    data = message.split(/,?\s+/)

    if data.length.zero?
      report
    else
      write data[0], data[1..-1].collect(&:downcase)
      report
    end
  end

  private

  attr_reader :robot, :redis, :user, :message

  def report
    hash = schedule[user.mention_name]
    if hash.nil?
      say "No standup scheduled"
    else
      say "Standup scheduled for #{hash["time"]} on #{hash["days"].join(", ")}"
    end
  end

  def schedule
    @schedule ||= JSON.load schedule_raw
  end

  def schedule_raw
    raw = redis.get("lita-standup:schedule")
    return "{}" if raw.nil? || raw.empty?

    raw
  end

  def say(message)
    robot.send_message Lita::Source.new(:user => user), message
  end

  def write(time, days)
    schedule[user.mention_name] = {"time" => time, "days" => days}

    redis.set "lita-standup:schedule", JSON.dump(schedule)
  end
end
