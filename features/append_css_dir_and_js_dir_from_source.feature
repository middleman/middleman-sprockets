Feature: The js_dir & css_dir from Middleman are appended to sprockets

  Scenario: While using defaults for js_dir & css_dir
    Given the Server is running at "base-app"

    Then sprockets paths should include "source/stylesheets"
    And sprockets paths should include "source/javascripts"


  Scenario: While using custom paths for js_dir & css_dir
    Given the Server is running at "custom-dir-app"

    Then sprockets paths should include "source/assets/css"
    And sprockets paths should include "source/assets/scripts"

