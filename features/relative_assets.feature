Feature: Asset helpers give relative paths when asked
  Scenario: Issue #19
    Given the Server is running at "jquery-mobile-app"
    When I go to "/stylesheets/base.css"
    Then I should see "../images/jquery-mobile/icons-36-white.png"