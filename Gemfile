source 'https://rubygems.org'

gemspec

gem 'middleman-cli',  github: 'middleman/middleman', branch: 'master'
gem 'middleman-core', github: 'middleman/middleman', branch: 'master'

# Build and doc tools
gem 'rake', '~> 10.3',  require: false
gem 'yard', '~> 0.8',   require: false

# Test tools
gem 'pry-byebug'
gem 'aruba',    '~> 0.7.4', require: false
gem 'rspec',    '~> 3.0',   require: false
gem 'cucumber', '~> 2.0',   require: false

# For actual tests
# Make sure to lock down the versions of the asset gems
# so they don't cause asset hashes to change.
gem 'railties',            '~> 4.2.0'
gem 'jquery-rails',        '3.1.0',   require: false
gem 'bootstrap-sass',      '3.1.1.0', require: false
gem 'jquery_mobile_rails', '1.4.1',   require: false
gem 'sass-globbing',       '1.1.1',   require: false

gem 'ejs',    '~> 1.1.1'
gem 'eco',    '~> 1.0.0'
gem 'erubis', '~> 2.7.0'
gem 'haml',   '~> 4.0', require: false

# Code Quality
group :test do
  gem 'rubocop',    '~> 0.37.2', require: false
  gem 'simplecov',  '~> 0.9',    require: false
  gem 'coveralls',  '~> 0.8',    require: false
  gem 'codeclimate-test-reporter', '~> 0.3', require: false
end
