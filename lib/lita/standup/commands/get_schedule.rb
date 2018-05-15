class Lita::Standup::Commands::GetSchedule
  def self.call(robot, redis, user)
    new(robot, redis, user).call
  end

  def initialize(robot, redis, user)
    @robot = robot
    @redis = redis
    @user  = user
  end

  def call
    hash = schedule[user.mention_name]

    if hash.nil?
      say "No standup scheduled"
    else
      say "Standup scheduled for #{hash["time"]} on #{hash["days"].join(", ")}"
    end
  end

  private

  attr_reader :robot, :redis, :user

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
end
