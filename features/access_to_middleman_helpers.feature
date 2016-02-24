Feature: Helpers added to middleman are available to sprockets assets

  Scenario: Helpers render correctly with sprockets asset when config'd to expose helpers
    Given a fixture app "middleman-helpers-app"
    And a file named "config.rb" with:
      """
      activate :sprockets do |c|
        c.expose_middleman_helpers = true
      end

      helpers do
        def hello
          'hello'
        end
      end
      """
    And the Server is running

    When I go to "/index.html"
    Then I should see "<h1>hello</h1>"

    When I go to "/javascripts/site.js"
    Then I should see "console.log('hello');"

    When I go to "/javascripts/importer.js"
    Then I should see "console.log('hello');"

  Scenario: Helpers show exception with sprockets asset when not config'd to expose helpers
    Given a fixture app "middleman-helpers-app"
    And a file named "config.rb" with:
      """
      activate :sprockets

      helpers do
        def hello
          'hello'
        end
      end
      """
    And the Server is running

    When I go to "/index.html"
    Then I should see "<h1>hello</h1>"

    When going to "/javascripts/site.js" should not raise an exception
    Then I should see "undefined local variable or method `hello'"

    When going to "/javascripts/importer.js" should not raise an exception
    Then I should see "undefined local variable or method `hello'"
