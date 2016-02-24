set :css_dir, "assets/css"

activate :sprockets
sprockets.append_path File.join(root, 'resources/assets')
# sprockets.import_asset "stylesheets/test"
