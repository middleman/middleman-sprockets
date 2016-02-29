Feature: Asset paths from gems are appended to sprockets' paths

  Scenario: Hodor
    Given the Server is running at "base-app"

    Then sprockets paths should include gem path "assets_gem/vendor/assets/css"
    And sprockets paths should include gem path "assets_gem/vendor/assets/fonts"
    And sprockets paths should include gem path "assets_gem/vendor/assets/images"
    And sprockets paths should include gem path "assets_gem/vendor/assets/javascripts"
