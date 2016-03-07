module Middleman
  class SprocketsExtension
    class Interface
      attr_reader :options, :environment

      def initialize options, environment
        @options     = options
        @environment = environment

        @processible = if ::Sprockets::VERSION >= '4.0'
          ProcessibleFour.new(environment, options)
        else
          ProcessibleThree.new(environment)
        end
      end

      def processible? filename
        @processible.call(filename, options[:supported_output_extensions])
      end

      class ProcessibleFour
        attr_reader :extensions,
                    :environment,
                    :options

        def initialize environment, options
          @options     = options
          @environment = environment

          acceptable_mimes = options[:supported_output_extensions].map do |ext|
            environment.config[:mime_exts][ext]
          end
          @extensions = environment.transformers.map { |k, v| [k, v.keys] }.select do |row|
                          acceptable_mimes.include?(row.first) ||
                            row.last.include?(acceptable_mimes.first) ||
                            row.last.include?(acceptable_mimes.last)
                        end.flat_map do |row|
                          mime = row.first
                          environment.mime_exts.map { |k, v| v == mime ? k : nil }.compact
                        end
        end

        def call filename, output_exts
          file_ext, _mime = ::Sprockets::PathUtils.match_path_extname(filename, environment.config[:mime_exts])
          extensions.include?(file_ext)
        end

      end

      class ProcessibleThree

        attr_reader :extensions

        def initialize environment
          @extensions = environment.engines.keys
        end

        def call filename, output_exts
          *template_exts, target_ext = Middleman::Util.collect_extensions(filename)
          output_exts.include?(target_ext) && (template_exts - extensions).empty?
        end
      end

    end
  end
end
