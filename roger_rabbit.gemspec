# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "roger_rabbit/version"

Gem::Specification.new do |s|
  s.name        = "roger_rabbit"
  s.version     = RogerRabbit::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joe Van Dyk"]
  s.email       = ["joe@tanga.com"]
  s.homepage    = "http://github.com/joevandyk/roger_rabbit"
  s.summary     = %q{Sweet wrapper around the bunny rabbitmq library}
  s.description = %q{Sweet wrapper around the bunny rabbitmq library}

  s.rubyforge_project = "roger_rabbit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "bunny"
  s.add_dependency "json"
  s.add_dependency "activesupport"
end
