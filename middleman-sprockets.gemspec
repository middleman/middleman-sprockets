# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-sprockets/version"

Gem::Specification.new do |s|
  s.name = "middleman-sprockets"
  s.version = Middleman::Sprockets::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Thomas Reynolds"]
  s.email = ["me@tdreyno.com"]
  s.homepage = "https://github.com/middleman/middleman-sprockets"
  s.summary = %q{Sprockets support for Middleman}
  s.description = %q{Sprockets support for Middleman}
  s.license = "MIT"
  s.files = `git ls-files -z`.split("\0")
  s.test_files = `git ls-files -z -- {fixtures,features}/*`.split("\0")
  s.require_paths = ["lib"]
  s.add_dependency("middleman-core", [">= 3.0.14"])
  s.add_dependency("sprockets", ["~> 2.1"])
  s.add_dependency("sprockets-sass", ["~> 1.0.0"])
  s.add_dependency("sprockets-helpers", ["~> 1.0.0"])
  # We must depend on padrino-helpers so that middleman-core loads its helpers
  s.add_dependency("padrino-helpers", ["0.10.7"])
end