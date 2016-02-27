Given /^wait a second$/ do
  sleep(1)
end

Given /^binding.pry/ do
  binding.pry
end


Then /^sprockets paths should include "([^\"]*)"$/ do |path|
  sprockets = @server_inst.extensions[:sprockets].environment
  expect( sprockets.paths ).to include File.join(ENV['MM_ROOT'], path)
end

Then /^sprockets paths should include gem path "([^\"]*)"/ do |path|
  sprockets = @server_inst.extensions[:sprockets].environment
  expect( sprockets.paths ).to include File.join(PROJECT_ROOT_PATH, 'fixtures', 'gems', path)
end
