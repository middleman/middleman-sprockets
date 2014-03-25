require "sprockets"
require "sprockets-sass"
require "middleman-sprockets/config_only_environment"
require "middleman-sprockets/environment"
require "middleman-sprockets/asset_tag_helpers"

# Sprockets extension
module Middleman
  class SprocketsExtension < Extension
    option :debug_assets, false, 'Split up each required asset into its own script/style tag instead of combining them (development only)'

    attr_reader :environment

    # This module gets mixed into both the Middleman instance and the Middleman class,
    # so that it's available in config.rb
    module SprocketsAccessor
      # The sprockets environment
      # @return [Middleman::MiddlemanSprocketsEnvironment]
      def sprockets
        extensions[:sprockets].environment
      end
    end

    def initialize(app, options_hash={}, &block)
      require "middleman-sprockets/sass_function_hack"

      super

      # Start out with a stub environment that can only be configured (paths and such)
      @environment = ::Middleman::Sprockets::ConfigOnlyEnvironment.new

      app.send :include, SprocketsAccessor
    end

    helpers do
      include SprocketsAccessor
      include ::Middleman::Sprockets::AssetTagHelpers
    end

    def before_configuration
      if defined?(::Middleman::ConfigContext)
        app.add_to_config_context :sprockets, &method(:environment)
      end
    end

    def after_configuration
      ::Tilt.register ::Sprockets::EjsTemplate, 'ejs'
      ::Tilt.register ::Sprockets::EcoTemplate, 'eco'
      ::Tilt.register ::Sprockets::JstProcessor, 'jst'

      if app.respond_to?(:template_extensions)
        app.template_extensions :jst => :js, :eco => :js, :ejs => :js
      end

      if app.config.defines_setting?(:debug_assets) && !options.setting(:debug_assets).value_set?
        options[:debug_assets] = app.config[:debug_assets]
      end

      config_environment = @environment
      debug_assets = !app.build? && options[:debug_assets]
      @environment = ::Middleman::Sprockets::Environment.new(app, :debug_assets => debug_assets)
      config_environment.apply_to_environment(@environment)

      add_assets_from_gems

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
      imported_assets = []
      environment.imported_assets.each do |asset_logical_path|
        assets = []
        environment.resolve(asset_logical_path) do |asset|
          assets << asset
          @app.logger.debug "== Importing Sprockets asset #{asset}"
        end
        raise ::Sprockets::FileNotFound, "couldn't find asset '#{asset_logical_path}'" if assets.empty?
        imported_assets += assets
      end

      resources_list = []
      environment.paths.each do |load_path|
        output_dir = nil
        export_all = false
        if load_path.end_with?('/images')
          output_dir = @app.config[:images_dir]
          export_all = true
        elsif load_path.end_with?('/fonts')
          output_dir = @app.config[:fonts_dir]
          export_all = true
        elsif load_path.end_with?('/stylesheets')
          output_dir = @app.config[:css_dir]
        elsif load_path.end_with?('/javascripts')
          output_dir = @app.config[:js_dir]
        end

        environment.each_entry(load_path) do |path|
          next unless path.file?
          next if path.basename.to_s.start_with?('_')

          next unless export_all || imported_assets.include?(path)

          # For all imported assets that aren't in an obvious directory, figure out their
          # type (and thus output directory) via extension.
          output_dir ||= case File.extname(path)
                         when '.js', '.coffee'
                           @app.config[:js_dir]
                         when '.css', '.sass', '.scss', '.styl', '.less'
                           @app.config[:css_dir]
                         when '.gif', '.png', '.jpg', '.jpeg', '.svg', '.svg.gz'
                           @app.config[:images_dir]
                         when '.ttf', '.woff', '.eot', '.otf'
                           @app.config[:fonts_dir]
                         end

          if !output_dir
            raise ::Sprockets::FileNotFound, "couldn't find an appropriate output directory for '#{path}' - halting because it was explicitly requested via 'import_asset'"
          end

          base_path = path.sub("#{load_path}/", '')
          new_path = @app.sitemap.extensionless_path(File.join(output_dir, base_path))

          next if @app.sitemap.find_resource_by_destination_path(new_path)
          resources_list << ::Middleman::Sitemap::Resource.new(@app.sitemap, new_path.to_s, path.to_s)
        end
      end
      resources + resources_list
    end

    private

    # Add any directories from gems with Rails-like paths to sprockets load path
    def add_assets_from_gems
      try_paths = [
                   %w{ assets },
                   %w{ app },
                   %w{ app assets },
                   %w{ vendor },
                   %w{ vendor assets },
                   %w{ lib },
                   %w{ lib assets }
                  ].inject([]) do |sum, v|
        sum + [
               File.join(v, 'javascripts'),
               File.join(v, 'stylesheets'),
               File.join(v, 'images'),
               File.join(v, 'fonts')
              ]
      end

      ([app.root] + ::Middleman.rubygems_latest_specs.map(&:full_gem_path)).each do |root_path|
        try_paths.map {|p| File.join(root_path, p) }.
          select {|p| File.directory?(p) }.
          each {|path| self.environment.append_path(path) }
      end
    end
  end
end
