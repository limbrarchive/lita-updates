class Lita::Standup::Commands::Data
  def initialize(redis, response)
    @redis    = redis
    @response = response
  end

  def export
    response.reply "JSON: \`#{redis.get("lita-standup:schedule")}\`"
  end

  def import
    json = response.message.body.gsub(/^standup import\s+/, "")
    redis.set "lita-standup:schedule", json

    response.reply "The schedule data has been updated."
  end

  private

  attr_reader :redis, :response
end
