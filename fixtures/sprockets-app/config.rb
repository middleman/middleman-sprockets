set :js_dir, "library/js"
set :css_dir, "library/css"

sprockets.append_path File.expand_path('bower_components', root)

after_configuration do
  sprockets.append_path File.join(root, 'vendor/assets')
  sprockets.import_asset "stylesheets/vendored.css"
  sprockets.import_asset "javascripts/coffee.js"
end