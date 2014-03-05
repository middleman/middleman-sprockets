Feature: Bower
  Scenario: Sprockets can pull underscore from bower
    Given the Server is running at "bower-app"
    When I go to "/javascripts/application.js"
    Then I should see "return _;"

  Scenario: Sprockets can build underscore from bower
    Given a successfully built app at "bower-app"
    When I cd to "build"
    Then the following files should exist:
      | javascripts/application.js |
    And the file "javascripts/application.js" should contain "return _;"

  Scenario: Sprockets should not mess with bower.json
    Given a successfully built app at "bower-json-app"
    When I cd to "build"
    Then the following files should exist:
      | javascripts/bower.json |
    And the file "javascripts/bower.json" should contain '"name": "my-project",'

  Scenario: Assets can be added to the build with import_asset from bower dir
    Given a successfully built app at "bower-app"
    When I cd to "build"
    Then a file named "javascripts/underscore/underscore.js" should exist
