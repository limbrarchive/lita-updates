require "json"

class Lita::Standup::Schedule
  def self.call(robot, redis)
    new(robot, redis).call
  end

  def initialize(robot, redis)
    @robot = robot
    @redis = redis
  end

  def call
    schedule.each do |username, hash|
      user = Lita::User.fuzzy_find username
      next unless user

      Lita::Timing::Scheduled.new(
        "standup-#{user.mention_name}", redis
      ).daily_at(
        time_for(user, hash["time"]), hash["days"].collect(&:to_sym)
      ) do
        puts "Starting standup with #{user.mention_name}"
        Lita::Standup::Conversation.new(robot, redis, user).call
      end
    end
  end

  private

  attr_reader :robot, :redis

  def schedule
    @schedule ||= JSON.load schedule_raw
  end

  def schedule_raw
    raw = redis.get("lita-standup:schedule")
    return "{}" if raw.nil? || raw.empty?

    raw
  end

  def time_for(user, time)
    user   = extended_user_for user
    now    = Time.now
    offset = user.metadata["tz_offset"] || now.utc_offset
    hours, minutes = time.split(":").collect(&:to_i)

    Time.new(now.year, now.month, now.day, hours, minutes, 0, offset).utc.
      strftime("%k:%M").strip
  end

  def extended_user_for(user)
    case Lita.config.robot.adapter
    when :slack
      Lita::Adapters::Slack::SlackUser.from_data robot.chat_service.api.send(
        :call_api, "users.info", :user => user.id
      )["user"]
    else
      user
    end
  rescue => error
    puts "Error finding user #{username}"
    user
  end
end
