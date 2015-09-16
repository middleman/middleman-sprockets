require "sprockets"
require "middleman-core/sitemap/resource"

module Middleman
  class SprocketsExtension < Extension
    attr_reader :environment

    expose_to_config sprockets: :environment

    def initialize(app, options_hash={}, &block)
      super

      @inline_asset_references = Set.new

      @environment = ::Sprockets::Environment.new

      app.config.define_setting :sprockets_imported_asset_path, "assets", "Where under source should imported assets be placed."
    end

    def after_configuration
      @environment.append_path((app.source_dir + app.config[:js_dir]).to_s)
      @environment.append_path((app.source_dir + app.config[:css_dir]).to_s)

      append_paths_from_gems

      the_app = app
      the_env = environment

      @environment.context_class.send(:define_method, :app) { the_app }
      @environment.context_class.send(:define_method, :data) { the_app.data }
      @environment.context_class.send(:define_method, :env) { the_env }

      @environment.context_class.class_eval do
        def asset_path(path, options = {})
          # Handle people calling with the Middleman/Padrino asset path signature
          if path.is_a?(::Symbol) && !options.is_a?(::Hash)
            kind = path
            path = options
          else

          kind = case options[:type]
                 when :image then :images
                 when :font then :fonts
                 when :javascript then :js
                 when :stylesheet then :css
                 else options[:type]
                 end
          end

          if app.extensions[:sprockets].check_asset(path)
            "/#{app.config[:sprockets_imported_asset_path]}/#{path}"
          else
            app.asset_path(kind, path)
          end
        end
      end
    end

    def base_resource?(r)
      r.class.ancestors.first == ::Middleman::Sitemap::Resource
    end

    def js?(r)
      begin
        r.source_file.start_with?((app.source_dir + app.config[:js_dir]).to_s)
      rescue
        require 'pry'
        binding.pry
      end
    end

    def css?(r)
      r.source_file.start_with?((app.source_dir + app.config[:css_dir]).to_s)
    end

    def check_asset(path)
      if asset = environment[path]
        @inline_asset_references << path
        true
      else
        false
      end
    end

    def manipulate_resource_list(resources)
      sprockets, non_sprockets = resources.partition do |r|
        base_resource?(r) && (js?(r) || css?(r))
      end

      non_sprockets + sprockets.reduce([]) do |sum, r|
        sprockets_path = if js?(r)
          r.path.sub(%r{^#{app.config[:js_dir]}\/}, '')
        else
          r.path.sub(%r{^#{app.config[:css_dir]}\/}, '')
        end

        sprockets_resource = generate_resource(r.path, r.source_file, sprockets_path)
        sum << sprockets_resource

        if sprockets_resource.respond_to?(:sprockets_asset)
          sprockets_resource.sprockets_asset.links.each do |a|
            asset = environment[a]
            path = "#{app.config[:sprockets_imported_asset_path]}/#{asset.logical_path}"
            sum << generate_resource(path, asset.filename, asset.logical_path)
          end
        end

        sum
      end + @inline_asset_references.map do |path|
        asset = environment[path]
        path = "#{app.config[:sprockets_imported_asset_path]}/#{asset.logical_path}"  
        generate_resource(path, asset.filename, asset.logical_path)
      end
    end

    private

    def generate_resource(path, source_file, sprockets_path)
      begin
        SprocketsResource.new(app.sitemap, path, source_file, sprockets_path, environment)
      rescue Exception => e
        raise e if app.build?

        ext = File.extname(path)
        error_message = if ext == '.css'
          css_exception_response(e)
        elsif ext == '.js'
          javascript_exception_response(e)
        else
          e.to_s
        end

        ::Middleman::Sitemap::StringResource.new(app.sitemap, path, error_message)
      end
    end

    # Returns a JavaScript response that re-throws a Ruby exception
    # in the browser
    def javascript_exception_response(exception)
      err  = "#{exception.class.name}: #{exception.message}\n  (in #{exception.backtrace[0]})"
      "throw Error(#{err.inspect})"
    end

    # Returns a CSS response that hides all elements on the page and
    # displays the exception
    def css_exception_response(exception)
      message   = "\n#{exception.class.name}: #{exception.message}"
      backtrace = "\n  #{exception.backtrace.first}"

      <<-CSS
        html {
          padding: 18px 36px;
        }

        head {
          display: block;
        }

        body {
          margin: 0;
          padding: 0;
        }

        body > * {
          display: none !important;
        }

        head:after, body:before, body:after {
          display: block !important;
        }

        head:after {
          font-family: sans-serif;
          font-size: large;
          font-weight: bold;
          content: "Error compiling CSS asset";
        }

        body:before, body:after {
          font-family: monospace;
          white-space: pre-wrap;
        }

        body:before {
          font-weight: bold;
          content: "#{escape_css_content(message)}";
        }

        body:after {
          content: "#{escape_css_content(backtrace)}";
        }
      CSS
    end

    # Escape special characters for use inside a CSS content("...") string
    def escape_css_content(content)
      content.
        gsub('\\', '\\\\005c ').
        gsub("\n", '\\\\000a ').
        gsub('"',  '\\\\0022 ').
        gsub('/',  '\\\\002f ')
    end

    # Backwards compatible means of finding all the latest gemspecs
    # available on the system
    #
    # @private
    # @return [Array] Array of latest Gem::Specification
    def rubygems_latest_specs
      # If newer Rubygems
      if ::Gem::Specification.respond_to? :latest_specs
        ::Gem::Specification.latest_specs(true)
      else
        ::Gem.source_index.latest_specs
      end
    end

    # Add any directories from gems with Rails-like paths to sprockets load path
    def append_paths_from_gems
      root_paths = rubygems_latest_specs.map(&:full_gem_path) << app.root
      base_paths = %w[assets app app/assets vendor vendor/assets lib lib/assets]
      asset_dirs = %w[javascripts js stylesheets css images img fonts]

      root_paths.product(base_paths.product(asset_dirs)).each do |root, (base, asset)|
        path = File.join(root, base, asset)
        environment.append_path(path) if File.directory?(path)
      end
    end

    class SprocketsResource < ::Middleman::Sitemap::Resource
      def initialize(store, path, source_file, sprockets_path, environment)
        @path = path
        @sprockets_path = sprockets_path
        @environment = environment
        @source = sprockets_asset.source

        super(store, path, source_file)
      end

      def template?
        true
      end

      def render(*)
        @source
      end

      def sprockets_asset
        @environment[@sprockets_path]
      end

      def binary?
        false
      end
    end
  end
end