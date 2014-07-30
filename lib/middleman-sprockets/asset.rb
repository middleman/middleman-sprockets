# encoding: utf-8
module Middleman
  module Sprockets
    # Asset 
    class Asset

      private

      attr_reader :relative_source_path, :base_name, :destination_directory, :source_directory

      public

      attr_reader :source_path

      # Create instance
      #
      # @param [Pathname] logical_path
      #   The logical path to the asset given in config.rb
      #
      # @param [proc] output_dir
      #   An individual output directory for that particular asset
      def initialize(source_path, options)
        source_directory = options.fetch(:source_directory, nil)

        fail ArgumentError, 'Missing argument source_directory' unless source_directory

        @source_directory     = source_directory

        @source_path          = Pathname.new(source_path)
        @relative_source_path = @source_path.relative_path_from(Pathname.new(source_directory))
        @base_name            = @source_path.basename
        @import_it            = false
      end

      # Should the asset imported?
      #
      # @return [true, false]
      #   Is true if it should be imported
      def import?
        valid? && (in_trusted_source_directory? || import_it?)
      end

      # Check on file type
      #
      # @return [true, false]
      #   Is true if has type
      def has_type?(t)
        type == t
      end

      # Path where the asset should be stored
      #
      # @return [Pathname]
      #    Returns `destination_path` if set, otherwise build result: destination_directory + relative_source_path
      #
      # @raise [::Sprockets::FileNotFound]
      #   Raise error if destination_directory was not set previously from outside
      def destination_path
        return @destination_path if @destination_path

        fail ::Sprockets::FileNotFound, "Couldn't find an appropriate output directory for '#{destination_directory}' - halting because it was explicitly requested via 'import_asset'" unless destination_directory

        destination_directory + relative_source_path
      end

      # Sets the destination_path
      #
      # @param [String,Pathname] path
      #   The output path for asset as string or pathname. It will be converted
      #   to `Pathname`.
      def destination_path=(path)
        @destination_path = Pathname.new path
      end

      # Set destination directory
      #  
      #  @param [String] path
      #    The path to the destination directory
      #
      #  @return [Pathname]
      #    The path as pathname
      def destination_directory=(path)
        @destination_directory = Pathname.new path
      end

      # Check if given path matches source_path
      #
      # @param [String] path
      #   The path to be checked
      # @return [true, false]
      #   The result of check
      def match?(path)
        source_path == Pathname.new(path)
      end

      # Tell asset that it is importable
      def import_it
        @import_it = true # single =
      end

      private

      def in_trusted_source_directory?
        is_in_images_directory? || is_in_fonts_directory?
      end

      def type
        if is_in_images_directory? or is_image?
          :image
        elsif is_in_scripts_directory? or is_script?
          :script
        elsif is_in_stylesheets_directory? or is_stylesheet?
          :stylesheet
        elsif is_in_fonts_directory? or is_font?
          :font
        else
          :unknown
        end
      end

      def file?
        source_path.file?
      end

      def partial?
        base_name.start_with? '_'
      end

      # Is it a valid asset
      # @return [true, false]
      #   If the asset is valid return true
      def valid?
        file? && !partial?
      end

      def import_it?
        @import_it == true # double =
      end

      def has_extname?(*exts)
        exts.any? { |e| extname == e }
      end

      def extname
        source_path.extname
      end

      def has_real_path?(path)
        real_path == path
      end

      def is_in_images_directory?
        source_directory.end_with?('images', 'img') 
      end

      def is_in_fonts_directory?
        source_directory.end_with?('fonts') 
      end

      def is_in_scripts_directory?
        source_directory.end_with?('javascripts', 'js')
      end

      def is_in_stylesheets_directory?
        source_directory.end_with?('stylesheets', 'css') 
      end

      def is_image?
        has_extname?('.gif', '.png', '.jpg', '.jpeg', '.svg', '.svg.gz')
      end

      def is_stylesheet?
        has_extname?('.css', '.sass', '.scss', '.styl', '.less')
      end

      def is_font?
        has_extname?('.ttf', '.woff', '.eot', '.otf')
      end

      def is_script?
        has_extname?('.js', '.coffee')
      end
    end
  end
end
