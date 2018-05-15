class Lita::Updates::Data
  def initialize(redis, user)
    @redis = redis
    @user  = user
  end

  def read(key)
    redis.get("#{user.mention_name}:#{key}")
  end

  def write(key, value)
    redis.set("#{user.mention_name}:#{key}", value)
  end

  private

  attr_reader :redis, :user
end
