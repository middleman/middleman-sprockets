Feature: Ignoring Imported Assets
  Background: App with imported assets ignoring some of them
    Given a fixture app "sprockets-app"
    And a file named "config.rb" with:
      """
      set :js_dir,  "library/js"
      set :css_dir, "library/css"

      sprockets.ignore_path /jquery/
      """
    And the Server is running

  Scenario: Imported jquery assets are not in the sitemap (but others are)
    Then the sitemap should not include "/images/jquery-mobile/ajax-loader.gif"
    And the sitemap should include "/fonts/bootstrap/glyphicons-halflings-regular.eot"

  Scenario: Assets from imported gem can still be required
    When I go to "/library/js/jquery_include.js"
    Then I should see "window.jQuery ="