module Lita
  module Handlers
    class Standup < Handler
      MINUTE = 60 # seconds

      config :target

      on :loaded,            :set_up_schedule
      on :unhandled_message, :continue_standup

      route /^standup$/i, :command => true, :help => {
        "standup" => "Provide a standup report on demand"
      } do |response|
        Lita::Updates::Commands::Standup.call robot, redis, response.user
      end

      route /^standup schedule$/i, :command => true,
        :help => {"standup schedule" => "Display your current schedule"} do |response|
        Lita::Updates::Commands::GetSchedule.call robot, redis, response.user
      end

      route /^standup schedule clear$/, :command => true,
        :help => {"standup schedule clear" => "Clear your scheduled standup"} do |response|
        Lita::Updates::Commands::ClearSchedule.call robot, redis, response.user
      end

      route /^standup schedule \d/i, :command => true,
        :help => {"standup schedule" => "Specify hour and days. e.g. `standup schedule 16:00 monday tuesday friday`"} do |response|
        Lita::Updates::Commands::SetSchedule.call robot, redis, response.user,
          response.message.body.gsub('standup schedule', '').strip
      end

      route /^standup export$/i, :command => true do |response|
        Lita::Updates::Commands::Data.new(redis, response).export
      end

      route /^standup import/i,  :command => true do |response|
        Lita::Updates::Commands::Data.new(redis, response).import
      end

      def continue_standup(payload)
        message = payload[:message]

        # Only respond to private messages or testing locally:
        return unless message.source.private_message || Lita.config.robot.adapter == :shell

        # Ensure messages are not from the bot:
        return if message.user.mention_name == robot.mention_name

        # Continue the standup discussion
        Lita::Updates::Commands::Standup.call robot, redis, message.user,
          message
      end

      def set_up_schedule(payload)
        every(MINUTE) { |timer| Lita::Updates::Schedule.call robot, redis }
      end
    end
  end
end

Lita.register_handler(Lita::Handlers::Standup)
