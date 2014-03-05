ready do
  sprockets.append_path File.join(root, 'bower_components')

  # This should really be just 'underscore' but we are testing against
  # an ancient version of sprockets that doesn't understand bower.
  sprockets.import_asset 'underscore/underscore'
end
