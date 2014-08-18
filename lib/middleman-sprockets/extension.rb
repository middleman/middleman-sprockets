require "sprockets"
require "sprockets-sass"
require "middleman-sprockets/asset"
require "middleman-sprockets/imported_asset"
require "middleman-sprockets/asset_list"
require "middleman-sprockets/config_only_environment"
require "middleman-sprockets/environment"
require "middleman-sprockets/asset_tag_helpers"

class Sprockets::Sass::SassTemplate
  # Get the default, global Sass options. Start with Compass's
  # options, if it's available.
  def default_sass_options
    if defined?(Compass) && defined?(Compass.configuration)
      merge_sass_options Compass.configuration.to_sass_engine_options.dup, Sprockets::Sass.options
    else
      Sprockets::Sass.options.dup
    end
  end
end

# Sprockets extension
module Middleman
  class SprocketsExtension < Extension
    option :debug_assets, false, 'Split up each required asset into its own script/style tag instead of combining them (development only)'

    attr_reader :environment

    def initialize(app, options_hash={}, &block)
      require "middleman-sprockets/sass_function_hack"

      super

      # Start out with a stub environment that can only be configured (paths and such)
      @environment = ::Middleman::Sprockets::ConfigOnlyEnvironment.new
      app.add_to_config_context :sprockets, &method(:environment)
    end

    helpers do
      def sprockets
        extensions[:sprockets].environment
      end
    end

    helpers ::Middleman::Sprockets::AssetTagHelpers

    def after_configuration
      ::Tilt.register ::Sprockets::EjsTemplate, 'ejs'
      ::Tilt.register ::Sprockets::EcoTemplate, 'eco'
      ::Tilt.register ::Sprockets::JstProcessor, 'jst'

      if app.config.defines_setting?(:debug_assets) && !options.setting(:debug_assets).value_set?
        options[:debug_assets] = app.config[:debug_assets]
      end

      config_environment = @environment
      debug_assets = !app.build? && options[:debug_assets]
      @environment = ::Middleman::Sprockets::Environment.new(app, :debug_assets => debug_assets)
      config_environment.apply_to_environment(@environment)

      # Setup Sprockets Sass options
      if app.config.defines_setting?(:sass)
        app.config[:sass].each { |k, v| ::Sprockets::Sass.options[k] = v }
      end

      # Intercept requests to /javascripts and /stylesheets and pass to sprockets
      our_sprockets = self.environment

      [app.config[:js_dir], app.config[:css_dir], app.config[:images_dir], app.config[:fonts_dir]].each do |dir|
        app.map("/#{dir}") { run our_sprockets }
      end
    end

    # Add sitemap resource for every image in the sprockets load path
    def manipulate_resource_list(resources)
      imported_assets = Middleman::Sprockets::AssetList.new

      environment.imported_assets.each do |asset|
        asset.resolve_path_with environment
        @app.logger.debug "== Importing Sprockets asset #{asset.real_path}"

        imported_assets << asset
      end

      resources_list = []
      environment.paths.each do |load_path|
        environment.each_entry(load_path) do |path|
          asset = Middleman::Sprockets::Asset.new(path, source_directory: load_path)

          imported_assets.lookup(asset) do |candidate, found_asset| 
            candidate.destination_path = found_asset.output_path if found_asset.output_path
            candidate.import_it
          end

          next unless asset.import?

          if asset.has_type? :image
            asset.destination_directory = @app.config[:images_dir]
          elsif asset.has_type? :script
            asset.destination_directory = @app.config[:js_dir]
          elsif asset.has_type? :font
            asset.destination_directory = @app.config[:fonts_dir]
          elsif asset.has_type? :stylesheet
            asset.destination_directory = @app.config[:css_dir]
          end

          new_path = @app.sitemap.extensionless_path(asset.destination_path.to_s)

          next if @app.sitemap.find_resource_by_destination_path(new_path.to_s)
          
          source_file = ::Middleman::SourceFile.new(
            new_path, path, Pathname(load_path), :asset)

          resources_list << ::Middleman::Sitemap::Resource.new(@app.sitemap, new_path.to_s, source_file)
        end
      end
      resources + resources_list
    end
  end
end
