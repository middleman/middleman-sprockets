Feature: Linked assets are included in the sitemap
  Assets that are linked, either through a `//= link` directive or with an asset url helper (like `asset_path`) will be included in the sitemap & built automatically. The path these assets are placed at is configurable with the `:imported_asset_path` option.

  Note that we're taking advantage of the fact that the `assets_gem` is included in the sprockets paths with these examples.

  Scenario: Assets linked with a Sprockets directive
    Given a fixture app "base-app"
    And a file named "config.rb" with:
      """
      activate :sprockets
      """
    And a file named "source/stylesheets/site.css.scss" with:
      """
      //= link logo.png
      """
    And the Server is running

    When I go to "/assets/logo.png"
    Then the status code should be "200"


  Scenario: Assets linked using a path helper
    Given a fixture app "base-app"
    And a file named "config.rb" with:
      """
      activate :sprockets
      """
    And a file named "source/stylesheets/site.css.scss" with:
      """
      body {
        background: image-url('logo.png');
      }
      """
    And the Server is running

    When I go to "/assets/logo.png"
    Then the status code should be "200"


  Scenario: Linked asset destination is configurable
    Given a fixture app "base-app"
    And a file named "config.rb" with:
      """
      activate :sprockets do |c|
        c.imported_asset_path = 'linked'
      end
      """
    And a file named "source/stylesheets/site.css.scss" with:
      """
      //= link logo.png
      """
    And the Server is running

    When I go to "/linked/logo.png"
    Then the status code should be "200"
