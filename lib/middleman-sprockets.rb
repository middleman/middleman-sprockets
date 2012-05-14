require "middleman-core"
require "middleman-more"
require "middleman-sprockets/version"

Middleman::Extensions.register(:sprockets, Middleman::Sprockets::VERSION) do
  require "middleman-sprockets/extension"
  Middleman::Sprockets
end