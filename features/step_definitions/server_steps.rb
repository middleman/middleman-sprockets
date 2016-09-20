Given /^wait a second$/ do
  sleep(1)
end

Given /^binding\.pry$/ do
  require "pry"
  binding.pry
end

Then /^the sitemap should not include "([^\"]*)"$/ do |path|
  expect( @server_inst.sitemap.resources.map(&:url) ).not_to include path
end

Then /^the sitemap should include "([^\"]*)"$/ do |path|
  expect( @server_inst.sitemap.resources.map(&:url) ).to include path
end