require "sprockets"
require "sprockets-sass"
require "middleman-sprockets/sass_function_hack"

# Sprockets extension
module Middleman::Sprockets

  # Setup extension
  class << self

    # Once registered
    def registered(app)
      # Add class methods to context
      app.send :include, InstanceMethods

      app.helpers JavascriptTagHelper
      app.helpers StylesheetTagHelper

      ::Tilt.register ::Sprockets::EjsTemplate, 'ejs'
      ::Tilt.register ::Sprockets::EcoTemplate, 'eco'
      ::Tilt.register ::Sprockets::JstProcessor, 'jst'

      app.after_configuration do
        template_extensions :jst => :js, :eco => :js, :ejs => :js 

        sitemap.rebuild_resource_list!

        # Add any gems with (vendor|app|.)/assets/javascripts to paths
        # also add similar directories from project root (like in rails)
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

        ([root] + ::Middleman.rubygems_latest_specs.map(&:full_gem_path)).each do |root_path|
          try_paths.map {|p| File.join(root_path, p) }.
            select {|p| File.directory?(p) }.
            each {|path| sprockets.append_path(path) }
        end

        # Setup Sprockets Sass options
        sass.each { |k, v| ::Sprockets::Sass.options[k] = v }

        # Intercept requests to /javascripts and /stylesheets and pass to sprockets
        our_sprockets = sprockets

        map("/#{js_dir}")  { run our_sprockets }
        map("/#{css_dir}") { run our_sprockets }
        map("/#{images_dir}") { run our_sprockets }
        map("/#{fonts_dir}") { run our_sprockets }

        # register resource list manipulator to add assets_load_paths to sitemap
        sitemap.register_resource_list_manipulator(:assets_load_paths, SitemapExtension.new(self), false)
      end
    end
    alias :included :registered
  end

  module InstanceMethods
    # @return [Middleman::CoreExtensions::Sprockets::MiddlemanSprocketsEnvironment]
    def sprockets
      @sprockets ||= MiddlemanSprocketsEnvironment.new(self)
    end
  end

  # Generic Middleman Sprockets env
  class MiddlemanSprocketsEnvironment < ::Sprockets::Environment
    # Setup
    def initialize(app)
      @imported_assets = []
      @app = app

      super app.source_dir

      # By default, sprockets has no cache! Give it an in-memory one using a Hash
      @cache = {}

      enhance_context_class!

      # Remove compressors, we handle these with middleware
      unregister_bundle_processor 'application/javascript', :js_compressor
      unregister_bundle_processor 'text/css', :css_compressor

      # configure search paths
      append_path app.js_dir
      append_path app.css_dir
      append_path app.images_dir
      append_path app.fonts_dir
      append_path app.bower_dir if app.respond_to?(:bower_dir)

      # add custom assets paths to the scope
      app.js_assets_paths.each do |p|
        warn ":js_assets_paths is deprecated. Call sprockets.append_path instead."
        append_path p
      end if app.respond_to?(:js_assets_paths)

      # Stylus support
      if defined?(::Stylus)
        require 'stylus/sprockets'
        ::Stylus.setup(self, app.styl)
      end
    end

    # Add our own customizations to the Sprockets context class
    def enhance_context_class!
      app = @app

      # Make the app context available to Sprockets
      context_class.send(:define_method, :app) { app }

      context_class.class_eval do
        def asset_path(path, options={})
          # Handle people calling with the Middleman/Padrino asset path signature
          if path.is_a?(::Symbol) && !options.is_a?(::Hash)
            return app.asset_path(path, options)
          end

          kind = case options[:type]
                 when :image then :images
                 when :font then :fonts
                 when :javascript then :js
                 when :stylesheet then :css
                 else options[:type]
                 end

          app.asset_path(kind, path)
        end

        # These helpers are already defined in later versions of Sprockets, but we define
        # them ourself to help older versions and to provide extra options that Sass wants.

        # Expand logical image asset path.
        def image_path(path, options={})
          asset_path(path, :type => :image)
        end

        # Expand logical font asset path.
        def font_path(path, options={})
          # Knock .fonts off the end, because Middleman < 3.1 doesn't handle fonts
          # in asset_path
          asset_path(path, :type => :font).sub(/\.fonts$/, '')
        end

        # Expand logical javascript asset path.
        def javascript_path(path, options={})
          asset_path(path, :type => :javascript)
        end

        # Expand logical stylesheet asset path.
        def stylesheet_path(path, options={})
          asset_path(path, :type => :stylesheet)
        end

        def method_missing(*args)
          name = args.first
          if app.respond_to?(name)
            app.send(*args)
          else
            super
          end
        end

        # Needed so that method_missing makes sense
        def respond_to?(method, include_private = false)
          super || app.respond_to?(method, include_private)
        end
      end
    end
    private :enhance_context_class!

    # Override Sprockets' default digest function to *not*
    # change depending on the exact Sprockets version. It still takes
    # into account "version" which is a user-suppliable version
    # number that can be used to force assets to have a new
    # hash.
    def digest
      @digest ||= Digest::SHA1.new.update(version.to_s)
      @digest.dup
    end

    # Strip our custom 8-char hex/sha
    def path_fingerprint(path)
      path[/-([0-9a-f]{8})\.[^.]+$/, 1]
    end

    # Invalidate sitemap when users mess with the sprockets load paths
    def append_path(*args)
      @app.sitemap.rebuild_resource_list!(:sprockets_paths)
      super
    end

    def prepend_path(*args)
      @app.sitemap.rebuild_resource_list!(:sprockets_paths)
      super
    end

    def clear_paths
      @app.sitemap.rebuild_resource_list!(:sprockets_paths)
      super
    end

    def css_exception_response(exception)
      raise exception if @app.build?
      super
    end

    def javascript_exception_response(exception)
      raise exception if @app.build?
      super
    end

    def call(env)
      # Set the app current path based on the full URL so that helpers work
      request_path = URI.decode(File.join(env['SCRIPT_NAME'], env['PATH_INFO']))
      if request_path.respond_to? :force_encoding
        request_path.force_encoding('UTF-8')
      end
      resource = @app.sitemap.find_resource_by_destination_path(request_path)

      debug_assets = @app.respond_to?(:debug_assets) && @app.debug_assets && !@app.build?
      if !resource && !debug_assets
        response = ::Rack::Response.new
        response.status = 404
        response.write """<html><body><h1>File Not Found</h1><p>#{request_path}</p>
          <p>If this is an an asset from a gem, add <tt>sprockets.import_asset '#{File.basename(request_path)}'</tt>
          to your <tt>config.rb</tt>.</body>"""
        return response.finish
      end

      @app.current_path = request_path

      super
    end

    # A list of Sprockets logical paths for assets that should be brought into the
    # Middleman application and built.
    attr_accessor :imported_assets

    # Tell Middleman to build this asset, referenced as a logical path.
    def import_asset(asset_logical_path)
      imported_assets << asset_logical_path
    end
  end

  module JavascriptTagHelper

    # extend padrinos javascript_include_tag with debug functionality
    # splits up script dependencies in individual files when
    # configuration variable :debug_assets is set to true
    def javascript_include_tag(*sources)
      if respond_to?(:debug_assets) && debug_assets && !build?
        options = sources.extract_options!.symbolize_keys

        # loop through all sources and the dependencies and
        # output each as script tag in the correct order
        sources.map do |source|
          source_file_name = source.to_s

          dependencies_paths = if source_file_name.start_with?('//', 'http')
            # Don't touch external sources
            source_file_name
          else
            source_file_name << ".js" unless source_file_name.end_with?(".js")

            sprockets[source_file_name].to_a.map do |dependency|
              # if sprockets sees "?body=1" it only gives back the body
              # of the script without the dependencies included
              dependency.logical_path + "?body=1"
            end
          end

          super(dependencies_paths, options)
        end.join("").gsub("body=1.js", "body=1")
      else
        super
      end
    end
  end

  module StylesheetTagHelper

    # extend padrinos stylesheet_link_tag with debug functionality
    # splits up stylesheets dependencies in individual files when
    # configuration variable :debug_assets is set to true
    def stylesheet_link_tag(*sources)
      if respond_to?(:debug_assets) && debug_assets && !build?
        options = sources.extract_options!.symbolize_keys
        # loop through all sources and the dependencies and
        # output each as script tag in the correct order
        
        sources.map do |source|
          source_file_name = source.to_s

          dependencies_paths = if source_file_name.start_with?('//', 'http')
            # Don't touch external sources
            source_file_name
          else
            source_file_name << ".css" unless source_file_name.end_with?(".css")

            dependencies_paths = sprockets[source_file_name].to_a.map do |dependency|
              # if sprockets sees "?body=1" it only gives back the body
              # of the script without the dependencies included
              dependency.logical_path + "?body=1"
            end
          end

          super(dependencies_paths, options)
        end.join("").gsub("body=1.css", "body=1")
      else
        super
      end
    end
  end

  class SitemapExtension
    def initialize(app)
      @app = app
    end

    # Add sitemap resource for every image in the sprockets load path
    def manipulate_resource_list(resources)
      sprockets = @app.sprockets

      imported_assets = []
      sprockets.imported_assets.each do |asset_logical_path|
        assets = []
        sprockets.resolve(asset_logical_path) do |asset|
          assets << asset
          @app.logger.debug "== Importing Sprockets asset #{asset}"
        end
        raise ::Sprockets::FileNotFound, "couldn't find asset '#{asset_logical_path}'" if assets.empty?
        imported_assets.concat(assets)
      end

      resources_list = []
      sprockets.paths.each do |load_path|
        output_dir = nil
        export_all = false
        if load_path.end_with?('/images')
          output_dir = @app.images_dir
          export_all = true
        elsif load_path.end_with?('/fonts')
          output_dir = @app.fonts_dir
          export_all = true
        elsif load_path.end_with?('/stylesheets')
          output_dir = @app.css_dir
        elsif load_path.end_with?('/javascripts')
          output_dir = @app.js_dir
        end

        if output_dir
          sprockets.each_entry(load_path) do |path|
            next unless path.file?
            next if path.basename.to_s.start_with?('_')
            next unless export_all || imported_assets.include?(path)

            base_path = path.sub("#{load_path}/", '')
            new_path = @app.sitemap.extensionless_path(File.join(output_dir, base_path))

            next if @app.sitemap.find_resource_by_destination_path(new_path)
            resources_list << ::Middleman::Sitemap::Resource.new(@app.sitemap, new_path.to_s, path.to_s)
          end
        end
      end
      resources + resources_list
    end
  end
end
