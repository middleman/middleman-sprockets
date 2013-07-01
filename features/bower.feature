Feature: Bower
  Scenario: Sprockets can pull jQuery from bower
    Given the Server is running at "bower-app"
    When I go to "/javascripts/get_jquery.js"
    Then I should see "window.jQuery ="

  Scenario: Sprockets can build jQuery from bower
    Given a successfully built app at "bower-app"
    When I cd to "build"
    Then the following files should exist:
      | javascripts/get_jquery.js |
    And the file "javascripts/get_jquery.js" should contain "window.jQuery ="