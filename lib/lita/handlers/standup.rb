module Lita
  module Handlers
    class Standup < Handler
      config :target

      route /^standup$/i, :standup, :command => true, :help => {
        "standup" => "Provide a standup report on demand"
      }

      def self.dispatch(robot, message)
        super(robot, message) ||
          new(robot).on_message_received(:message => message)
      end

      def standup(response)
        start_standup_with response.user.mention_name
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
