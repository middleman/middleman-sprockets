module Middleman
  class SprocketsExtension
    class SprocketsResource < ::Middleman::Sitemap::Resource
      def initialize store, path, source_file, sprockets_path, environment
        @app  = store.app
        @path = path
        @sprockets_path = sprockets_path
        @environment    = environment
        @errored        = false

        super(store, path, source_file)
      end

      def errored?
        @errored
      end

      def template?
        true
      end

      def render *_args
        sprockets_asset.source
      end

      def sprockets_asset
        @environment[@sprockets_path]
      rescue StandardError => e
        raise e if @app.build?

        @errored = true
        Error.new(e, ext)
      end

      def binary?
        false
      end

      class Error

        def initialize error, ext
          @error = error
          @ext   = ext
        end

        def links
          []
        end

        def source
          case @ext
          when '.css' then css_response
          when '.js' then js_response
          else
            default_response
          end
        end
        alias to_s source

        private

          def default_response
            @error.to_s
          end

          def js_response
            file, line = @error.backtrace[0].split(':')
            err = "#{@error.class.name}: #{@error.message}\n" \
                  "  on line #{line} of #{file})"

            "throw Error(#{err.inspect})"
          end

          def css_response
            ::Sass::SyntaxError.exception_to_css(@error)
          end

      end

    end
  end
end
