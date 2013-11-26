module Middleman
  module Sprockets
    # Generic Middleman Sprockets env
    class MiddlemanSprocketsEnvironment < ::Sprockets::Environment
      attr_accessor :options

      # Setup
      def initialize(app)
        @imported_assets = []
        @app = app
        @options = {}

        super app.source_dir

        # By default, sprockets has no cache! Give it a file-based cache so that
        # the cache is persisted between sessions
        @cache = ::Sprockets::Cache::FileStore.new(File.join app.root, '.cache')

        enhance_context_class!

        # Remove compressors, we handle these with middleware
        unregister_bundle_processor 'application/javascript', :js_compressor
        unregister_bundle_processor 'text/css', :css_compressor

        # configure search paths
        append_path app.js_dir
        append_path app.css_dir
        append_path app.images_dir
        append_path app.fonts_dir

        if app.respond_to?(:bower_dir)
          warn ":bower_dir is deprecated. Call sprockets.append_path from a 'ready' block instead."
          append_path app.bower_dir
        end

        # add custom assets paths to the scope
        app.js_assets_paths.each do |p|
          warn ":js_assets_paths is deprecated. Call sprockets.append_path from a 'ready' block instead."
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

        debug_assets = !@app.build? && (@options.debug_assets || (@app.respond_to?(:debug_assets) && @app.debug_assets))
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
  end
end
