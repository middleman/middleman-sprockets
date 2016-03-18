module Middleman
  class SprocketsExtension
    class Interface
      attr_reader :options,
                  :environment,
                  :extensions

      def initialize options, environment
        @options     = options
        @environment = environment
        setup!
      end

      module Sprockets4
        def setup!
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

        def processible? filename
          file_ext, _mime = ::Sprockets::PathUtils.match_path_extname(filename, environment.config[:mime_exts])
          extensions.include?(file_ext)
        end
      end

      module Sprockets3
        def setup!
          @extensions = environment.engines.keys
        end

        def processible? filename
          *template_exts, target_ext = Middleman::Util.collect_extensions(filename)
          options[:supported_output_extensions].include?(target_ext) && (template_exts - extensions).empty?
        end
      end

      if ::Sprockets::VERSION >= '4.0'
        include Sprockets4
      else
        include Sprockets3
      end
    end
  end
end
