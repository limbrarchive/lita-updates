class Lita::Standup::Commands::ClearSchedule
  def self.call(robot, redis, user)
    new(robot, redis, user).call
  end

  def initialize(robot, redis, user)
    @robot = robot
    @redis = redis
    @user  = user
  end

  def call
    schedule.delete user.mention_name

    redis.set "lita-standup:schedule", JSON.dump(schedule)

    Lita::Standup::Commands::GetSchedule.call robot, redis, user
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
end
