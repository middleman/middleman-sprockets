Feature: Files with unhandled file extensions are ignored

  Scenario: HTML & Dotfiles in css_dir or js_dir are handled by middleman only
    Given a fixture app "sprockets-app"
    And a file named "source/library/js/.jslintrc" with:
      """
      {"bitwise":true}
      """
    And a file named "source/library/js/index.html.erb" with:
      """
      <h1><%= current_resource.url %></h1>
      """
    And the Server is running

    When I go to "/library/js/.jslintrc"
    Then I should see '{"bitwise":true}'

    When I go to "/library/js"
    Then I should see "<h1>/library/js/</h1>"

  Scenario: Files with Tilt templates, but not supported by sprockets, are handled properly
    Given a fixture app "sprockets-app"
    And a file named "source/library/js/index.js.haml" with:
      """
      :plain
        alert('why haml?');
      """
    And the Server is running

    When I go to "/library/js/index.js"
    Then I should see "alert('why haml?');"
