module Middleman
  class SprocketsExtension
    class SprocketsResource < ::Middleman::Sitemap::Resource
      def initialize store, path, source_file, sprockets_path, environment, error_message: ''
        @path = path
        @sprockets_path = sprockets_path
        @environment    = environment
        @error_message  = error_message
        render()

        super(store, path, source_file)
      end

      def errored?
        !@error_message.empty?
      end

      def template?
        true
      end

      def render *_args
        errored? ? @error_message : sprockets_asset.source
      end

      def sprockets_asset
        @environment[@sprockets_path]
      end

      def binary?
        false
      end
    end
  end
end
