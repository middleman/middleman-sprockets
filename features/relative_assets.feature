Feature: Asset helpers give relative paths when asked
  Scenario: Issue #19 Preview
    Given the Server is running at "jquery-mobile-app"
    When I go to "/stylesheets/base.css"
    Then I should see "../images/jquery-mobile/icons-36-white.png"

  Scenario: Issue #19 Build
    Given a successfully built app at "jquery-mobile-app"
    When I cd to "../relative_build"
    Then the following files should exist:
      | stylesheets/base.css |
      | images/jquery-mobile/icons-36-white.png |
    And the file "stylesheets/base.css" should contain "images/jquery-mobile/icons-36-white.png"