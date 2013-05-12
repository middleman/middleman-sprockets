# sprockets-sass implements an image_url function that calls over to image_path. But bootstrap-sass
# defines an image_path function that calls image_url! To avoid the probem in bootstrap-sass (and anyone
# who tries something similar, this redefines sprockets-sass' function to not refer to image_path.
#
# See https://github.com/middleman/middleman/issues/864 for more info.
#
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

  # Also override generated_image_url to use Sprockets a la https://github.com/Compass/compass-rails/blob/98e4b115c8bb6395a1c3351926d574321396778b/lib/compass-rails/patches/3_1.rb
  def generated_image_url(path, only_path = nil)
    asset_url(path, Sass::Script::String.new("image"))
  end
end
