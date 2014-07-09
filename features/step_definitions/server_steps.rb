Then /^I should get a response with status "(.*?)"$/ do |status|
  expect((@last_response || @browser.last_response).status).to be status.to_i
end

Given /^wait a second$/ do
  sleep(1)
end
