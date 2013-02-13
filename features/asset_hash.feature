Feature: Assets get a file hash appended to their and references to them are updated
  Scenario: Hashed-asset files are produced, and HTML, CSS, and JavaScript gets rewritten to reference the new files
    Given a successfully built app at "asset-hash-app"
    When I cd to "build"
    Then the following files should exist:
      | index.html |
      | images/100px-1242c368.png |
      | images/100px-5fd6fb90.jpg |
      | images/100px-5fd6fb90.gif |
      | javascripts/application-df677242.js |
      | stylesheets/site-50eaa978.css |
      | index.html |
      | subdir/index.html |
      | other/index.html |
    And the following files should not exist:
      | images/100px.png |
      | images/100px.jpg |
      | images/100px.gif |
      | javascripts/application.js |
      | stylesheets/site.css |
      
    And the file "javascripts/application-df677242.js" should contain "img.src = '/images/100px-5fd6fb90.jpg'"
    And the file "stylesheets/site-50eaa978.css" should contain "background-image: url('../images/100px-5fd6fb90.jpg')"
    And the file "index.html" should contain 'href="stylesheets/site-50eaa978.css"'
    And the file "index.html" should contain 'src="javascripts/application-df677242.js"'
    And the file "index.html" should contain 'src="images/100px-5fd6fb90.jpg"'
    And the file "subdir/index.html" should contain 'href="../stylesheets/site-50eaa978.css"'
    And the file "subdir/index.html" should contain 'src="../javascripts/application-df677242.js"'
    And the file "subdir/index.html" should contain 'src="../images/100px-5fd6fb90.jpg"'
    And the file "other/index.html" should contain 'href="../stylesheets/site-50eaa978.css"'
    And the file "other/index.html" should contain 'src="../javascripts/application-df677242.js"'
    And the file "other/index.html" should contain 'src="../images/100px-5fd6fb90.jpg"'
    
  Scenario: Hashed assets work in preview server
    Given the Server is running at "asset-hash-app"
    When I go to "/"
    Then I should see 'href="stylesheets/site-50eaa978.css"'
    And I should see 'src="javascripts/application-df677242.js"'
    And I should see 'src="images/100px-5fd6fb90.jpg"'
    When I go to "/subdir/"
    Then I should see 'href="../stylesheets/site-50eaa978.css"'
    And I should see 'src="../javascripts/application-df677242.js"'
    And I should see 'src="../images/100px-5fd6fb90.jpg"'
    When I go to "/other/"
    Then I should see 'href="../stylesheets/site-50eaa978.css"'
    And I should see 'src="../javascripts/application-df677242.js"'
    And I should see 'src="../images/100px-5fd6fb90.jpg"'
    When I go to "/javascripts/application-df677242.js"
    Then I should see "img.src = '/images/100px-5fd6fb90.jpg'"
    When I go to "/stylesheets/site-50eaa978.css"
    Then I should see "background-image: url('../images/100px-5fd6fb90.jpg')"

  Scenario: Enabling an asset host still produces hashed files and references  
    Given the Server is running at "asset-hash-host-app"
    When I go to "/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-171eb3c0.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    When I go to "/subdir/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-171eb3c0.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    When I go to "/other/"
    Then I should see 'href="http://middlemanapp.com/stylesheets/site-171eb3c0.css"'
    And I should see 'src="http://middlemanapp.com/images/100px-5fd6fb90.jpg"'
    # Asset helpers don't appear to work from Compass right now
    # When I go to "/stylesheets/site-171eb3c0.css"
    # Then I should see "background-image: url('http://middlemanapp.com/images/100px-5fd6fb90.jpg')"

  Scenario: The asset hash should change when a SASS partial changes
    Given the Server is running at "asset-hash-app"
    And the file "source/stylesheets/_partial.sass" has the contents
      """
      body
        font-size: 14px
      """
    When I go to "/partials/"
    Then I should see 'href="../stylesheets/uses_partials-423a00f7.css'
    And the file "source/stylesheets/_partial.sass" has the contents
      """
      body
        font-size: 18px !important
      """
    When I go to "/partials/"
    Then I should see 'href="../stylesheets/uses_partials-e8c3d4eb.css'

  Scenario: The asset hash should change when a Javascript partial changes
    Given the Server is running at "asset-hash-app"
    And the file "source/javascripts/sprockets_sub.js" has the contents
      """
      function sprockets_sub_function() { }
      """
    When I go to "/partials/"
    Then I should see 'src="../javascripts/sprockets_base-0252a861.js'
    When I go to "/javascripts/sprockets_base-0252a861.js"
    Then I should see "sprockets_sub_function"
    And the file "source/javascripts/sprockets_sub.js" has the contents
      """
      function sprockets_sub2_function() { }
      """
    When I go to "/partials/"
    Then I should see 'src="../javascripts/sprockets_base-5121d891.js'
    When I go to "/javascripts/sprockets_base-5121d891.js"
    Then I should see "sprockets_sub2_function"