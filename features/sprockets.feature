Feature: Sprockets

  Scenario: Sprockets JS require
    Given the Server is running at "sprockets-app2"
    When I go to "/javascripts/sprockets_base.js"
    Then I should see "sprockets_sub_function"

  Scenario: javascript_include_tag with opts
    Given the Server is running at "sprockets-app"
    When I go to "/index.html"
    Then I should see "data-name"

  Scenario: asset_path helper
    Given the Server is running at "sprockets-app2"
    When I go to "/javascripts/asset_path.js"
    Then I should see "templates.js"

  Scenario: Sprockets JS require with custom :js_dir
    Given the Server is running at "sprockets-app"
    When I go to "/library/js/sprockets_base.js"
    Then I should see "sprockets_sub_function"

  Scenario: Plain JS require with custom :js_dir
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/plain.css"
    Then I should see "helloWorld"

  Scenario: Sprockets JS should have access to yaml data
    Given the Server is running at "sprockets-app2"
    When I go to "/javascripts/multiple_engines.js"
    Then I should see "Hello One"

  Scenario: Multiple engine files should build correctly
    Given a successfully built app at "sprockets-app2"
    When I cd to "build"
    Then a file named "javascripts/multiple_engines.js" should exist
    And the file "javascripts/multiple_engines.js" should contain "Hello One"

  Scenario: Sprockets CSS require //require
    Given the Server is running at "sprockets-app2"
    When I go to "/stylesheets/sprockets_base1.css"
    Then I should see "hello"

  Scenario: Sprockets CSS require @import
    Given the Server is running at "sprockets-app2"
    When I go to "/stylesheets/sprockets_base2.css"
    Then I should see "hello"

  Scenario: Sprockets CSS require with custom :css_dir //require
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/sprockets_base1.css"
    Then I should see "hello"

  Scenario: Plain CSS require with custom :css_dir
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/plain.css"
    Then I should see "helloWorld"

  Scenario: Sprockets CSS require with custom :css_dir @import
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/sprockets_base2.css"
    Then I should see "hello"

  Scenario: Sprockets inline Images with asset_path and image_path helpers
    Given the Server is running at "sprockets-images-app"
    When I go to "/"
    Then I should see 'src="/library/images/cat.jpg"'
    And I should see 'src="/library/images/cat-2.jpg"'
    When I go to "/library/images/cat.jpg"
    Then the status code should be "200"
    When I go to "/library/images/cat-2.jpg"
    Then the status code should be "200"

  Scenario: Assets built through import_asset are built with the right extension
    Given a successfully built app at "sprockets-app"
    When I cd to "build"
    # source file is /library/css/vendored.css.scss
    Then a file named "assets/vendored.css" should exist
    # source file is /library/css/coffee.js.coffee
    Then a file named "assets/coffee.js" should exist

  Scenario: Vendor assets get right extension
    Given the Server is running at "sprockets-app"
    # source file is /library/css/vendored.css.scss
    When I go to "/assets/vendored.css"
    And I should see 'background: brown;'
    # source file is /library/js/coffee.js.coffee
    When I go to "/assets/coffee.js"
    And I should see 'return console.log("bar");'

  Scenario: Assets built through import_asset are built with the right extension
    Given a successfully built app at "sprockets-svg-font-app"
    When I cd to "build"
    Then a file named "assets/font-awesome/fonts/fontawesome-webfont-bower.svg" should exist
    Then a file named "assets/font-awesome/fonts/fontawesome-webfont-bower.svg.gz" should exist
    Then a file named "assets/font-awesome/fonts/fontawesome-webfont-bower.ttf.gz" should exist
    Then a file named "fonts/fontawesome-webfont-source.svg" should exist
    Then a file named "fonts/fontawesome-webfont-source.svg.gz" should exist
    Then a file named "images/fontawesome-webfont-source.svg" should not exist
    Then a file named "images/drawing-source.svg" should exist
    Then a file named "assets/blub/images/drawing-bower.svg" should exist

  Scenario: Assets with multiple extensions
    Given a successfully built app at "sprockets-multiple-extensions-app"
    When I cd to "build"
    Then a file named "assets/font-awesome/fonts/fontawesome-webfont-bower.svg.gz" should exist
    Then a file named "assets/jquery/jquery.min.js" should exist
    Then a file named "assets/jquery/jquery.asdf.asdf.js.min.asdf" should exist
