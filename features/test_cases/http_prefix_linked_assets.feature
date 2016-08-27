Feature: Allow http_prefix to be prepended correctly to image-url when referencing a linked asset
  Background:
    Given a fixture app "linked-assets-app"
      And a file named "source/stylesheets/style.css.scss" with:
        """
        .foo {
          background: image-url("images/100px.gif");
        }
        """

  Scenario: Assets built have the correct http_prefix prepended
    Given a file named "config.rb" with:
      """
      activate :sprockets
      config[:http_prefix] = '/foo/bar'
      sprockets.append_path File.join(root, 'linked-assets')
      """
    And a successfully built app

    When I cd to "build"
    Then the following files should exist:
      | stylesheets/style.css |
      | assets/images/100px.gif |
    And the file "stylesheets/style.css" should contain:
      """
      .foo {
        background: url(/foo/bar/assets/images/100px.gif); }
      """

  Scenario: When http_prefix is not set, just prepend /
    Given a file named "config.rb" with:
      """
      activate :sprockets
      sprockets.append_path File.join(root, 'linked-assets')
      """
    And a successfully built app

    When I cd to "build"
    Then the file "stylesheets/style.css" should contain:
      """
      .foo {
        background: url(/assets/images/100px.gif); }
      """

  Scenario: relative_assets should still work
    Given a file named "config.rb" with:
      """
      activate :sprockets
      activate :relative_assets
      sprockets.append_path File.join(root, 'linked-assets')
      """
    And a successfully built app

    When I cd to "build"
    Then the file "stylesheets/style.css" should contain:
      """
      .foo {
        background: url(../assets/images/100px.gif); }
      """
