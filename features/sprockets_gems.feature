Feature: Sprockets Gems
  Scenario: Sprockets can pull jQuery from gem
    Given the Server is running at "sprockets-app"
    When I go to "/library/js/jquery_include.js"
    Then I should see "var jQuery ="
  
  # Scenario: Sprockets can pull CSS from gem
  #   Given the Server is running at "sprockets-app"
  #   When I go to "/library/css/bootstrap_include.css"
  #   Then I should see "Bootstrap"
  
  Scenario: Sprockets can pull js from vendored assets
    Given the Server is running at "sprockets-app"
    When I go to "/library/js/vendored_include.js"
    Then I should see "var vendored_js_included = true;"
  
  Scenario: Sprockets can pull js from custom vendor dir
    Given the Server is running at "asset-paths-app"
    When I go to "/javascripts/vendored_include.js"
    Then I should see "var vendored_js_included = true;"

  Scenario: Custom paths added to extension load their assets
    Given the Server is running at "assets-load-paths-app"
    When I go to "/"
    Then I should see '/pictures/test.jpg'
    When I go to "/pictures/test.jpg"
    Then I should get a response with status "200"
    When I go to "/stylesheets/all.css"
    Then I should see 'url("/pictures/test.jpg")'