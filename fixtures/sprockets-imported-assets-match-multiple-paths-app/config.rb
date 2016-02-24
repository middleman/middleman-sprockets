set :css_dir, "assets/css"

activate :sprockets
sprockets.append_path File.join(root, 'vendor/assets')
# sprockets.import_asset "css/test"
