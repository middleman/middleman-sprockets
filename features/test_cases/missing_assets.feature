Feature: Handling of missing assets

  Scenario: Importing a missing sass file
    In Sprockets 4, with ruby Sass -- having environment available is required otherwise the printer for load path with fail.

    Given a fixture app "base-app"
    And a file named "config.rb" with:
      """
      # simulate not having sassc
      # trying to catch a spefic sprockets error
      #
      Object.send :remove_const, :SassC if defined?(SassC)
      activate :sprockets do |c|
        c.expose_middleman_helpers = true
      end
      """
    And a file named "source/stylesheets/site.css.scss" with:
      """
      @import "missing";
      """
    And the Server is running

    When I go to "/stylesheets/site.css"
    Then I should see "Error: File to import not found or unreadable: missing."
