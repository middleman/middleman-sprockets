Feature: Bower

  Background:
    Given a fixture app "base-app"
    And a file named "config.rb" with:
      """
      activate :sprockets
      sprockets.append_path File.join(root, "bower_components")
      """
    And a file named "bower_components/underscore/underscore.js" with:
      """
      var _ = {};
      return _;
      """
    And a file named "source/javascripts/application.js" with:
      """
      //= require underscore/underscore
      """

  Scenario: Sprockets can pull underscore from bower
    Given the Server is running

    Then sprockets paths should include "bower_components"
    When I go to "/javascripts/application.js"
    Then I should see "return _;"


  Scenario: Sprockets can build underscore from bower
    And a successfully built app

    When I cd to "build"
    Then the following files should exist:
      | javascripts/application.js |
    And the file "javascripts/application.js" should contain "return _;"


  Scenario: Sprockets should not mess with bower.json
    Given a file named "source/javascripts/bower.json" with:
      """
      {
        "name": "my-project",
        "version": "1.0.0",
        "main": "application.js"
      }
      """
    And a the Server is running

    When I go to "/javascripts/bower.json"
    Then I should see '"name": "my-project",'


  Scenario: Assets can be added to the sitemap with import_asset from bower dir
    Given a file named "source/javascripts/manifest.js" with:
      """
      //= link underscore/underscore
      """
    And the Server is running

    When I go to "/assets/underscore/underscore.js"
    Then I should see "return _;"


  Scenario: Assets which haven't been imported don't appear in output directory
    Given a file named "bower_components/underscore/hello.js" with:
      """
      console.log('hello');
      """
    And the Server is running

    When I go to "/assets/underscore/hello.js"
    Then the status code should be "404"


  Scenario: Assets can have an individual output directory
    Given a file named "vendor/assets/lightbox2/hello.js" with:
      """
      console.log('hello');
      """
    And a file named "config.rb" with:
      """
      activate :sprockets
      sprockets.append_path File.join(root, "bower_components")
      sprockets.append_path File.join(root, "vendor/assets")
      """
    And a file named "source/javascripts/manifest.js" with:
      """
      //= link underscore/underscore
      //= link lightbox2/hello
      """
    And the Server is running

    When I go to "/assets/underscore/underscore.js"
    Then I should see "return _;"

    When I go to "/assets/lightbox2/hello.js"
    Then I should see "console.log('hello');"
