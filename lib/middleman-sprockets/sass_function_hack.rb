# sprockets-sass implements an image_url function that calls over to image_path. But bootstrap-sass
# defines an image_path function that calls image_url! To avoid the probem in bootstrap-sass (and anyone
# who tries something similar, this redefines sprockets-sass' function to not refer to image_path.
#
# See https://github.com/middleman/middleman/issues/864 for more info.
#x
module Sass::Script::Functions
  def image_url(source, options = {}, cache_buster = nil)
    # Work with the Compass #image_url API
    if options.respond_to? :value
      case options.value
      when true
        return ::Sass::Script::String.new sprockets_context.image_path(source.value).to_s, :string
      else
        options = {}
      end
    end
    ::Sass::Script::String.new "url(\"#{sprockets_context.image_path(source.value, map_options(options)).to_s}\")"
  end
end
