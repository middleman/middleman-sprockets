require 'bundler'
Bundler::GemHelper.install_tasks

require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  t.cucumber_opts = "--color --tags ~@wip --strict --format #{ENV['CUCUMBER_FORMAT'] || 'Fivemat'}"
end

require 'rake/clean'

task :test => [:destroy_sass_cache, "cucumber"]

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
