master
===

3.1.3
===

* Fix files names like guids, which Sprockets thinks are asset hashes.

3.1.2
===

* Fix debug_assets for CSS

3.1.1
===

* Add sprockets-helpers to the list of dependencies to fix various path-related bugs. #34
* Patch generated_image_url so that Compass sprites work. middleman/middleman#890.
* Output .jst, .eco, and .ejs files with a .js extension. middleman/middleman#888.
* Fix :debug_assets for files that include scripts from gems. #29.
* :debug_assets will now expand CSS included via Sprockets requires as well as JavaScript. #30

3.1.0
===

* Hack around infinite recursion between bootstrap-sass and sprockets-sass. middleman/middleman#864
* Fix for fonts in Sass files having ".font" appended to them. middleman/middleman#866.
* Enable in-memory caching in Sprockets, so unchanged assets don't get recompiled when other assets change. #25
* Refuse to serve gem-assets that haven't been added to the Middleman sitemap. #23
* Allow importing JS/CSS assets from gems by their logical path, using `sprockets.import_asset`. #23
* Fix a bug where, when `:debug_assets` was enabled, refreshing the page would produce the wrong JavaScript include path. #26

3.0.11
===

* Fonts are now included in the Sprockets load path.
* When `:debug_assets` is on, do not add `?body=1` multiple times. #24
* :js_assets_paths configuration is deprecated in favor of just calling sprockets.append_path. #22
* Sprockets integration, especially with regard to helper methods, is significantly improved. #22
* Images and fonts from gems added to the Sprockets load path will now be copied to the build output. #22 
* Compatibility with newer Sprockets versions.

3.0.10
===

* No longer expire Sprockets index in development mode. #18

