Then /^I should see$/ do |contents|
  @browser.last_response.body.should include(contents)
end

Then /^I should get a response with status "(.*?)"$/ do |status|
  @browser.last_response.status.should == status.to_i
end

Given /^wait a second$/ do
  sleep(1)
end
