Feature: Sprockets Gems
  Scenario: Sprockets can pull jQuery from gem
    Given the Server is running at "sprockets-app"
    When I go to "/library/js/jquery_include.js"
    Then I should see "window.jQuery ="

  Scenario: Sprockets can pull CSS from gem
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/bootstrap_include.css"
    Then I should see ".btn-default"

  Scenario: Sprockets can pull js from vendored assets
    Given the Server is running at "sprockets-app"
    When I go to "/library/js/vendored_include.js"
    Then I should see "var vendored_js_included = true;"

  Scenario: Sprockets can pull js from custom vendor dir
    Given the Server is running at "asset-paths-app"
    When I go to "/javascripts/vendored_include.js"
    Then I should see "var vendored_js_included = true;"

  Scenario: Proper reference to images from a gem, in preview
    Given the Server is running at "jquery-mobile-app"
    When I go to "/stylesheets/base.css"
    Then I should see 'url("/assets/jquery-mobile/ajax-loader.gif")'

  Scenario: Proper reference to images from a gem, in build
    Given a successfully built app at "jquery-mobile-app"
    When I cd to "build"
    Then the following files should exist:
      | stylesheets/base.css |
      | assets/jquery-mobile/ajax-loader.gif |
    And the file "stylesheets/base.css" should contain 'url(/assets/jquery-mobile/ajax-loader.gif)'

  Scenario: Same thing, but with :relative_assets on
    Given a fixture app "jquery-mobile-app"
    And a file named "config.rb" with:
      """
      activate :relative_assets
      """
    Given the Server is running at "jquery-mobile-app"
    When I go to "/stylesheets/base.css"
    Then I should see 'url("../assets/jquery-mobile/ajax-loader.gif")'

  Scenario: JS/CSS from gems can be declared to be accessible
    Given the Server is running at "jquery-mobile-app"
    When I go to "/assets/jquery.mobile.js"
    Then the status code should be "200"
