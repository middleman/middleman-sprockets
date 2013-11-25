module Middleman
  module Sprockets
    module JavascriptTagHelper

      # extend padrinos javascript_include_tag with debug functionality
      # splits up script dependencies in individual files when
      # configuration variable :debug_assets is set to true
      def javascript_include_tag(*sources)
        if !build? && (sprockets.options.debug_assets || (respond_to?(:debug_assets) && debug_assets))
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
        if !build? && (sprockets.options.debug_assets || (respond_to?(:debug_assets) && debug_assets))
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
  end
end
