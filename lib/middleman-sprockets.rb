require "middleman-core"

Middleman::Extensions.register(:sprockets, auto_activate: :before_configuration) do
  require "middleman-sprockets/extension"
  Middleman::SprocketsExtension
end