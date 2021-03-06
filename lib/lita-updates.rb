require "lita"
require "lita-timing"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/handlers/updates"

Lita::Handlers::Updates.template_root File.expand_path(
  File.join("..", "..", "templates"),
 __FILE__
)

require "lita/updates"
