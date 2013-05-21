set :js_dir, "library/js"
set :css_dir, "library/css"

after_configuration do
  sprockets.import_asset "vendored.css"
end