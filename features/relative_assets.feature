Feature: Images and Sass from gems
  Scenario: Proper reference to images from a gem, in preview
    Given the Server is running at "jquery-mobile-app"
    When I go to "/stylesheets/base.css"
    Then I should see 'url("/images/jquery-mobile/icons-36-white.png")'

  Scenario: Proper reference to images from a gem, in build
    Given a successfully built app at "jquery-mobile-app"
    When I cd to "../relative_build"
    Then the following files should exist:
      | stylesheets/base.css |
      | images/jquery-mobile/icons-36-white.png |
    And the file "stylesheets/base.css" should contain 'url("/images/jquery-mobile/icons-36-white.png")'

  @wip
  Scenario: Same thing, but with :relative_assets on
    Given a fixture app "jquery-mobile-app"
    And a file named "config.rb" with:
      """
      activate :relative_assets
      """
    Given the Server is running at "jquery-mobile-app"
    When I go to "/stylesheets/base.css"
    Then I should see 'url("../images/jquery-mobile/icons-36-white.png")'
