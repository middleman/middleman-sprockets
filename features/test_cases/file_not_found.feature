Feature: Throw sane error when Sprockets doesn't find an asset

  Background:
    Given a fixture app "base-app"
    And a file named "config.rb" with:
      """
      activate :sprockets

      # trick to ensure sprockets has no paths to
      # lookup assets
      ready do
        sprockets.clear_paths
      end
      """
    And a file named "source/stylesheets/main.css.scss" with:
      """
      body { content: 'main'; }
      """
    And a file named "source/javascripts/main.js.coffee" with:
      """
      console.log 'main'
      """

  Scenario: When a file is removed, a FileNotFound is caught
    Given the Server is running

    When I go to "/stylesheets/main.css"
    Then I should see "Sprockets::FileNotFound: stylesheets/main.css"

    When I go to "/javascripts/main.js"
    Then I should see "Sprockets::FileNotFound: javascripts/main.js"
