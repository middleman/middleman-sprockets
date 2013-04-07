require "sprockets"
require "sprockets-sass"

# Sprockets extension
module Middleman::Sprockets

  # Setup extension
  class << self

    # Once registered
    def registered(app)
      # Location of javascripts external to source directory.
      # @return [Array]
      #   set :js_assets_paths, ["#{root}/assets/javascripts/", "/path/2/external/js/repository/"]

      # Add class methods to context
      app.send :include, InstanceMethods

      app.after_configuration do
        helpers JavascriptTagHelper

        ::Tilt.register ::Sprockets::EjsTemplate, 'ejs'
        ::Tilt.register ::Sprockets::EcoTemplate, 'eco'

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
      @app = app
      super app.source_dir

      # Make the app context available to Sprockets
      context_class.send(:define_method, :app) { app }

      context_class.class_eval do
        # Find the Middleman-compatible version of this file's path
        def mm_path
          @mm_path ||= app.sitemap.file_to_path(pathname.to_s)
        end

        def asset_path(*args)
          app.current_path = mm_path unless app.current_path
          app.asset_path(*args)
        end


        # Sprockets sends a second arg but padrino can't deal
        def image_path(*args)
          app.image_path(args.first)
        end

        # Define font_path to help out Sass
        def font_path(src, options)
          app.asset_path :fonts, src
        end

        def method_missing(*args)
          name = args.first
          if app.respond_to?(name)
            # Set the middleman application current path, since it won't
            # be set if the request came in through Sprockets and helpers
            # won't work without it.
            app.current_path = mm_path unless app.current_path
            app.send(*args)
          else
            super
          end
        end
      end

      # Remove compressors, we handle these with middleware
      unregister_bundle_processor 'application/javascript', :js_compressor
      unregister_bundle_processor 'text/css', :css_compressor

      # configure search paths
      append_path app.js_dir
      append_path app.css_dir
      append_path app.images_dir

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

    # Override Sprockets' default digest function to *not*
    # change depending on the exact Sprockets version. It still takes
    # into account "version" which is a user-suppliable version
    # number that can be used to force assets to have a new
    # hash.
    def digest
      @digest ||= Digest::SHA1.new.update(version.to_s)
      @digest.dup
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
          dependencies_paths = sprockets[source].to_a.map do |dependency|
            # if sprockets sees "?body=1" it only gives back the body
            # of the script without the dependencies included
            dependency.logical_path << "?body=1"
          end

          super(dependencies_paths, options)
        end.join("").gsub("body=1.js", "body=1")
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
      resources_list = []
       @app.sprockets.paths.each do |load_path|
        output_dir = nil
        if load_path.end_with?('/images')
          output_dir = @app.images_dir
        elsif load_path.end_with?('/fonts')
          output_dir = @app.fonts_dir
        end

        if output_dir
          @app.sprockets.each_entry(load_path) do |entry|
            next unless entry.file?
            base_path = entry.sub("#{load_path}/", '')
            new_path = File.join(output_dir, base_path)
            resources_list << ::Middleman::Sitemap::Resource.new(@app.sitemap, new_path.to_s, entry.to_s)
          end
        end
      end
      resources + resources_list
    end
  end
end
