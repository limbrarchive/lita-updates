class Lita::Updates::Commands::Data
  def initialize(redis, response)
    @redis    = redis
    @response = response
  end

  def export
    response.reply "JSON: \`#{redis.get("lita-updates:schedule")}\`"
  end

  def import
    json = response.message.body.gsub(/^standup import\s+/, "")
    redis.set "lita-updates:schedule", json

    response.reply "The schedule data has been updated."
  end

  private

  attr_reader :redis, :response
end
