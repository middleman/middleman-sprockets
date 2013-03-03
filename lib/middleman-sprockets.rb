require "middleman-core"
require "middleman-more"

Middleman::Extensions.register(:sprockets) do
  require "middleman-sprockets/extension"
  Middleman::Sprockets
end
