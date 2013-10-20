Feature: Sprockets

  Scenario: Sprockets JS require
    Given the Server is running at "sprockets-app2"
    When I go to "/javascripts/sprockets_base.js"
    Then I should see "sprockets_sub_function"
    
  Scenario: javascript_include_tag with opts
    Given the Server is running at "sprockets-app"
    When I go to "/index.html"
    Then I should see "data-name"

  Scenario: asset_path helper
    Given the Server is running at "sprockets-app2"
    When I go to "/javascripts/asset_path.js"
    Then I should see "templates.js"
    
  Scenario: Sprockets JS require with custom :js_dir
    Given the Server is running at "sprockets-app"
    When I go to "/library/js/sprockets_base.js"
    Then I should see "sprockets_sub_function"
    
  Scenario: Plain JS require with custom :js_dir
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/plain.css"
    Then I should see "helloWorld"
    
  Scenario: Sprockets JS should have access to yaml data
    Given the Server is running at "sprockets-app2"
    When I go to "/javascripts/multiple_engines.js"
    Then I should see "Hello One"
    
  Scenario: Sprockets JS should only contain body when requested
    Given the Server is running at "sprockets-app2"
    When I go to "/javascripts/sprockets_base.js?body=1"
    Then I should see "base"
    And I should not see "sprockets_sub_function"
    
  Scenario: Script tags should be provided individually while debugging assets
    Given the Server is running at "sprockets-app-debug-assets"
    When I go to "/index.html"
    Then I should see "data-name"
    Then I should see 'src="/javascripts/dependency2.js?body=1"'
    Then I should see 'src="/javascripts/dependency1.js?body=1"'
    Then I should see 'src="/javascripts/main.js?body=1"'

  Scenario: External script tags should not be changed
    Given the Server is running at "sprockets-app-debug-assets"
    When I go to "/index.html"
    Then I should see 'src="//domain.com/script.js"'
    Then I should see 'src="http://domain.com/script.js"'
    Then I should see 'src="https://domain.com/script.js"'

 Scenario: Sprockets CSS should only contain body when requested
    Given the Server is running at "sprockets-app-debug-assets"
    When I go to "/stylesheets/app.css?body=1"
    Then I should see "body"
    
  Scenario: Stylesheets tags should be provided individually while debugging assets
    Given the Server is running at "sprockets-app-debug-assets"
    When I go to "/index.html"
    Then I should see 'href="/stylesheets/app.css?body=1"'
    Then I should see 'href="/stylesheets/dependency1.css?body=1"'
    Then I should see 'href="/stylesheets/dependency2.css?body=1"'

  Scenario: External stylesheet tags should not be changed
    Given the Server is running at "sprockets-app-debug-assets"
    When I go to "/index.html"
    Then I should see 'href="//domain.com/styles.css"'
    Then I should see 'href="http://domain.com/styles.css"'
    Then I should see 'href="https://domain.com/styles.css"'

  Scenario: Multiple engine files should build correctly
    Given a successfully built app at "sprockets-app2"
    When I cd to "build"
    Then a file named "javascripts/multiple_engines.js" should exist
    And the file "javascripts/multiple_engines.js" should contain "Hello One"
  
  Scenario: Sprockets CSS require //require
    Given the Server is running at "sprockets-app2"
    When I go to "/stylesheets/sprockets_base1.css"
    Then I should see "hello"
    
  Scenario: Sprockets CSS require @import
    Given the Server is running at "sprockets-app2"
    When I go to "/stylesheets/sprockets_base2.css"
    Then I should see "hello"

  Scenario: Sprockets CSS require with custom :css_dir //require
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/sprockets_base1.css"
    Then I should see "hello"
    
  Scenario: Plain CSS require with custom :css_dir
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/plain.css"
    Then I should see "helloWorld"
    
  Scenario: Sprockets CSS require with custom :css_dir @import
    Given the Server is running at "sprockets-app"
    When I go to "/library/css/sprockets_base2.css"
    Then I should see "hello"

  Scenario: Sprockets inline Images with asset_path and image_path helpers
    Given the Server is running at "sprockets-images-app"
    When I go to "/"
    Then I should see 'src="/library/images/cat.jpg"'
    And I should see 'src="/library/images/cat-2.jpg"'
    When I go to "/library/images/cat.jpg"
    Then I should get a response with status "200"
    When I go to "/library/images/cat-2.jpg"
    Then I should get a response with status "200"

  Scenario: Assets built through import_asset are built with wrong extension
    Given a successfully built app at "sprockets-app"
    When I cd to "build"
    # generated file is /library/css/vendored.css.scss
    Then a file named "library/css/vendored.css" should exist
    # generated file is /library/css/coffee.js.coffee
    Then a file named "library/js/coffee.js" should exist

  Scenario: Vendor assets get wrong extension
    Given the Server is running at "sprockets-app"
    # generated file is /library/css/vendored.css.scss
    When I go to "/library/css/vendored.css"
    And I should see 'background: brown;'
    # generated file is /library/js/coffee.js.coffee
    When I go to "/library/js/coffee.js"
    And I should see 'return console.log("bar");'
