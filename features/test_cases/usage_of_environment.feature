Feature: Usage of MM's environment method in a Sprockets asset
  Background:
    Given a fixture app "base-app"
    And a file named "config.rb" with:
      """
      activate :sprockets do |c|
        c.expose_middleman_helpers = true
      end
      """
    And a file named "source/javascripts/site.js.erb" with:
      """
      console.log('<%= environment %>');
      console.log('In development? <%= environment?(:development) ? "yes" : "no" %>')
      """


  Scenario: Should output the sprockets environment in preview server
    Given the Server is running
    And I go to "/javascripts/site.js"

    Then I should see "console.log('development');"


  Scenario: Should output the sprockets environment on build
    Given a successfully built app
    And I cd to "build"

    Then the file "javascripts/site.js" should contain "console.log('production');"
