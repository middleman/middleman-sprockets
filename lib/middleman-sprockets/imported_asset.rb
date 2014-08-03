# encoding: utf-8
module Middleman
  module Sprockets
    # ImportedAsset 
    class ImportedAsset
      attr_reader :logical_path, :output_path, :real_path

      # Create instance
      #
      # @param [Pathname] logical_path
      #   The logical path to the asset given in config.rb
      #
      # @param [proc] output_dir
      #   An individual output directory for that particular asset
      def initialize(logical_path, determine_output_path = proc { nil })
        @logical_path = Pathname.new(logical_path)
        @output_path  = if output_path = determine_output_path.call(@logical_path)
                          Pathname.new(output_path)
                        else
                          nil
                        end
      end

      # Resolve logical path to real path
      # 
      # @param [#resolve] resolver
      #   The objects which is able to resolve a logical path
      def resolve_path_with(resolver)
        @real_path = resolver.resolve(logical_path)

        raise ::Sprockets::FileNotFound, "Couldn't find asset '#{logical_path}'" if real_path == nil || real_path == ''
      end

      # String representation of asset
      #
      # @return [String]
      #   The logical path as string
      def to_s
        logical_path.to_s
      end

      # Does the given patch matches asset
      # 
      # @param [Pathname] path
      #   The path to be checked
      def match?(path)
        has_real_path? path
      end

      private

      def has_real_path?(path)
        real_path == path
      end
    end
  end
end
