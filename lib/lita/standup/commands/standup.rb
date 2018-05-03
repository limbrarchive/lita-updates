class Lita::Standup::Commands::Standup
  def self.call(robot, redis, user, message = nil)
    new(robot, redis, user, message).call
  end

  def initialize(robot, redis, user, message)
    @robot   = robot
    @redis   = redis
    @user    = user
    @message = message
  end

  def call
    puts "Starting standup with #{user.mention_name}" if message.nil?
    Lita::Standup::Conversation.new(robot, redis, user, message).call
  end

  private

  attr_reader :robot, :redis, :user, :message
end
