class Lita::Standup::Commands::SetSchedule
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

    write data[0], data[1..-1].collect(&:downcase)

    Lita::Standup::Commands::GetSchedule.call robot, redis, user
  end

  private

  attr_reader :robot, :redis, :user, :message

  def schedule
    @schedule ||= JSON.load schedule_raw
  end

  def schedule_raw
    raw = redis.get("lita-standup:schedule")
    return "{}" if raw.nil? || raw.empty?

    raw
  end

  def write(time, days)
    schedule[user.mention_name] = {"time" => time, "days" => days}

    redis.set "lita-standup:schedule", JSON.dump(schedule)
  end
end
