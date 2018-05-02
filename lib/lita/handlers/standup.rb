module Lita
  module Handlers
    class Standup < Handler
      MINUTE = 60 # seconds

      config :target

      on :loaded, :set_up_schedule

      route /^standup$/i, :standup, :command => true, :help => {
        "standup" => "Provide a standup report on demand"
      }
      route /^standup schedule/i, :standup_schedule, :command => true,
        :help => {"standup schedule" => "Specify hour and days. e.g. `standup schedule 16:00 monday tuesday friday`"}
      route /^standup export$/i, :standup_export, :command => true
      route /^standup debug$/i, :standup_debug, :command => true

      def self.dispatch(robot, message)
        super(robot, message) ||
          new(robot).on_message_received(:message => message)
      end

      def on_message_received(payload)
        message = payload[:message]

        # Only respond to private messages or testing locally:
        return unless message.source.private_message || Lita.config.robot.adapter == :shell

        # Ensure messages are not from the bot:
        return if message.user.mention_name == robot.mention_name

        Lita::Standup::Conversation.new(
          robot, redis, message.user, message
        ).call
      end

      def set_up_schedule(payload)
        every(MINUTE) { |timer| Lita::Standup::Schedule.call robot, redis }
      end

      def standup(response)
        start_standup_with response.user.mention_name
      end

      def standup_debug(response)
        user = Lita::Adapters::Slack::SlackUser.from_data robot.chat_service.api.send(
          :call_api, "users.info", :user => response.user.id
        )["user"]

        robot.send_message(
          Lita::Source.new(user: response.user),
          user.metadata.inspect
        )
      end

      def standup_export(response)
        robot.send_message(
          Lita::Source.new(user: response.user),
          "JSON: \`#{redis.get("lita-standup:schedule")}\`"
        )
      end

      def standup_schedule(response)
        Lita::Standup::SetSchedule.call robot, redis, response.user,
          response.message.body.gsub('standup schedule', '').strip
      end

      private

      def start_standup_with(name)
        user = Lita::User.fuzzy_find(name)
        return unless user

        puts "Starting standup with #{user.mention_name}"
        Lita::Standup::Conversation.new(robot, redis, user).call
      end
    end
  end
end

Lita.register_handler(Lita::Handlers::Standup)
