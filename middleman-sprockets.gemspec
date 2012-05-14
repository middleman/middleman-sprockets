# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-sprockets/version"

Gem::Specification.new do |s|
  s.name        = "middleman-sprockets"
  s.version     = Middleman::Sprockets::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Reynolds"]
  s.email       = ["me@tdreyno.com"]
  s.homepage    = "https://github.com/middleman/middleman-sprockets"
  s.summary     = %q{Sprockets support for Middleman}
  s.description = %q{Sprockets support for Middleman}

  s.rubyforge_project = "middleman-sprockets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  # s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("middleman-core", Middleman::Sprockets::VERSION)
  s.add_dependency("sprockets", ["~> 2.2"])
  s.add_dependency("sprockets-sass", ["~> 0.8.0"])
end