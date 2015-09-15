require 'bundler'
Bundler::GemHelper.install_tasks

require 'cucumber/rake/task'
require 'rspec/core/rake_task'

require 'middleman-core/version'

Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  exempt_tags = ["--tags ~@wip"]
  t.cucumber_opts = "--color #{exempt_tags.join(" ")} --strict"
end

RSpec::Core::RakeTask.new(:spec) do |t|
  if RUBY_VERSION < '2.0'
    t.rspec_opts = '--tag ~@skip:one-nine'
  end
end

require 'rake/clean'

task :test => [:destroy_sass_cache, "cucumber", "spec"]

desc "Build HTML documentation"
task :doc do
  sh 'bundle exec yard'
end

desc "Destroy the sass cache from fixtures in case it messes with results"
task :destroy_sass_cache do
  Dir["fixtures/*/.sass-cache"].each do |dir|
    rm_rf dir
  end
end
