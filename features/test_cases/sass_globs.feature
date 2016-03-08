Feature: Sass should glob partials like sass-rails
  Including the `sass-globbing` gem ins required for sass globs to work.

  Background:
    Given a fixture app "base-app"
    And a file named "config.rb" with:
      """
      require 'sass-globbing'
      activate :sprockets
      """
    And a file named "source/stylesheets/main.css.scss" with:
      """
      @import "**/*";
      """
    And a file named "source/stylesheets/d1/_s1.scss" with:
      """
      .d1s1 { content: 'd1'; }
      """
    And a file named "source/stylesheets/d2/_s1.sass" with:
      """
      .d2s1
        content: 'd2'
      """
    And a file named "source/stylesheets/d2/d3/_s1.sass" with:
      """
      .d3s1
        content: 'd3'
      """
    And a file named "source/stylesheets/d2/d3/_s2.scss" with:
      """
      .d3s2 { content: 'd3'; }
      """

  @sprockets3
  Scenario: Sass globbing should work
    Given the Server is running
    When I go to "/stylesheets/main.css"
    Then I should see ".d1s1"
    And I should see ".d2s1"
    And I should see ".d3s1"
    And I should see ".d3s2"

  @sprockets4
  Scenario: Sass globbing should work
    Sass globbing does not work with SassC, but does still work with Sprockets 4 if using ruby Sass.

    Given a file named "config.rb" with:
      """
      Object.send :remove_const, :SassC # simulate not having sassc
      require 'sass-globbing'
      activate :sprockets
      """
    Given the Server is running
    When I go to "/stylesheets/main.css"
    Then I should see ".d1s1"
    And I should see ".d2s1"
    And I should see ".d3s1"
    And I should see ".d3s2"
