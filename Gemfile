source :rubygems

git "git://github.com/middleman/middleman.git", :branch => "3.0-stable" do
  gem "middleman"
  gem "middleman-core"
  gem "middleman-more"
end

# Specify your gem's dependencies in middleman-blog.gemspec
gemspec

group :development do
  gem "rake",     "~> 0.9.2"
  gem "rdoc",     "~> 3.9"
  gem "yard",     "~> 0.8.0"
  gem "pry"
end

group :test do
  gem "cucumber", "~> 1.2.0"
  gem "fivemat"
  gem "aruba",    "~> 0.4.11"
  gem "rspec",    "~> 2.7"

  # For actual tests
  gem "jquery-rails", "~> 2.0.1"
  # gem "bootstrap-rails", "0.0.5"
  # gem "zurb-foundation"
  gem "ejs"
  gem "eco"
end