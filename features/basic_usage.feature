Feature: Basic Usage

  At it's base, the middleman-sprockets extension hooks sprockets into Middleman so that Sprockets is used to render js & css files instead of Middleman. This gives you access to [sprockets directives](https://github.com/rails/sprockets#sprockets-directives) and automagically building linked assets.

  To use, activate the extension in `config.rb`:

    """ruby
    activate :sprockets
    """

  Scenario: CSS & JS files are rendered with Sprockets
    Given a fixture app "base-app"
    And a file named "config.rb" with:
      """
      activate :sprockets
      """
    And a file named "source/stylesheets/_partial.scss" with:
      """
      body { background: #fd0; }
      """
    And a file named "source/stylesheets/site.css.scss" with:
      """
      //= require '_partial'
      """
    And a file named "source/javascripts/_partial.js" with:
      """
      console.log('hello');
      """
    And a file named "source/javascripts/site.js" with:
      """
      //= require '_partial'
      """
    And the Server is running

    When I go to "/stylesheets/site.css"
    Then I should see:
      """
      body {
        background: #fd0; }
      """

    When I go to "/javascripts/site.js"
    Then I should see "console.log('hello');"

  Scenario: The default :css_dir or :js_dir are appended to Sprockets lookup paths
    Given a fixture app "base-app"
    And a file named "config.rb" with:
      """
      activate :sprockets
      """
    And the Server is running

    Then sprockets paths should include "source/stylesheets"
    And sprockets paths should include "source/javascripts"


  Scenario: Custom directories for :css_dir or :js_dir are appened to Sprockets lookup paths
    Given a fixture app "base-app"
    And a file named "config.rb" with:
      """
      activate :sprockets

      set :css_dir, "assets/css"
      set :js_dir,  "assets/scripts"
      """
    And the Server is running

    Then sprockets paths should include "source/assets/css"
    And sprockets paths should include "source/assets/scripts"
