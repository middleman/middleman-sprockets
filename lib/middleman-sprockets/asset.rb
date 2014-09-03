# encoding: utf-8
module Middleman
  module Sprockets
    # Asset 
    class Asset
      attr_reader :source_path, :relative_source_path, :base_name, :destination_directory, :source_directory

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

        @source_directory = source_directory

        @source_path = Pathname.new(source_path)
        @relative_source_path = @source_path.relative_path_from(Pathname.new(source_directory))
        @base_name = @source_path.basename
        @import_it = false
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

        fail ::Sprockets::FileNotFound, "Couldn't find an appropriate output directory for '#{source_path}'. Halting because it was explicitly requested via 'import_asset'" unless destination_directory

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

      def in_trusted_source_directory?
        source_directory.end_with?('images') ||
        source_directory.end_with?('fonts')
      end

      def type
        @type ||= if is_image?
                    :image
                  elsif is_script?
                    :script
                  elsif is_stylesheet?
                    :stylesheet
                  elsif is_font?
                    :font
                  else
                    :unknown
                  end
      end

      def file?
        source_path.file?
      end

      def partial?
        base_name.to_s.start_with? '_'
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
        !(extname & exts).empty?
      end

      def extname
        source_path.basename.to_s.scan(/(\.[^.]+)/).flatten
      end

      def is_image?
        is_image_by_path? || (is_image_by_extension? && !is_font_by_path?)
      end

      def is_image_by_path?
        File.basename(source_directory.to_s) == 'images' ||
        File.basename(source_directory.to_s) == 'img' ||
        source_path.dirname.basename.to_s == 'images' ||
        source_path.dirname.basename.to_s == 'img'
      end
      alias_method :is_in_images_directory?, :is_image_by_path?

      def is_image_by_extension?
        has_extname?(*%w(.gif .png .jpg .jpeg .webp .svg .svgz))
      end

      def is_stylesheet?
        is_stylesheet_by_path? || is_stylesheet_by_extension?
      end

      def is_stylesheet_by_extension?
        has_extname?(*%w(.css .sass .scss .styl .less))
      end

      def is_stylesheet_by_path?
        File.basename(source_directory.to_s) == 'stylesheets' ||
        File.basename(source_directory.to_s) == 'css' ||
        source_path.dirname.basename.to_s == 'stylesheets' ||
        source_path.dirname.basename.to_s == 'css'
      end

      def is_font?
        is_font_by_path? || is_font_by_extension?
      end

      def is_font_by_path?
        File.basename(source_directory.to_s) == 'fonts' ||
        source_path.dirname.basename.to_s == 'fonts'
      end
      alias_method :is_in_fonts_directory?, :is_font_by_path?

      def is_font_by_extension?
        has_extname?(*%w(.ttf .woff .eot .otf .svg .svgz))
      end

      def is_script?
        is_script_by_path? || is_script_by_extension?
      end

      def is_script_by_path?
        File.basename(source_directory.to_s) == 'javascripts' ||
        File.basename(source_directory.to_s) == 'js' ||
        source_path.dirname.basename.to_s == 'javascripts' ||
        source_path.dirname.basename.to_s == 'js'
      end

      def is_script_by_extension?
        has_extname?(*%w(.js .coffee))
      end
    end
  end
end
