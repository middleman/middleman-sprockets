Given /^wait a second$/ do
  sleep(1)
end

Given /^binding.pry/ do
  binding.pry
end

Given /^the file "([^\"]*)" content is changed to\:$/ do |name, content|
  step %Q{a file named "#{name}" with:}, content
  sleep 1
  system "touch #{File.join(ENV['MM_ROOT'], name)}"
end

Then /^sprockets paths should include "([^\"]*)"$/ do |path|
  sprockets = @server_inst.extensions[:sprockets].environment
  expect( sprockets.paths ).to include File.join(ENV['MM_ROOT'], path)
end

Then /^sprockets paths should include gem path "([^\"]*)"/ do |path|
  sprockets = @server_inst.extensions[:sprockets].environment
  expect( sprockets.paths ).to include File.join(PROJECT_ROOT_PATH, 'fixtures', 'gems', path)
end
