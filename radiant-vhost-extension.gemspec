# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "radiant-vhost-extension/version"

Gem::Specification.new do |s|
  s.name        = "radiant-vhost-extension"
  s.version     = Radiant::VhostExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Garber, Jim Gay, Edmund Haselwanter, Ryan Krug, Wes Gamble"]
  s.email       = ["jim@saturnflyer.com"]
  s.homepage    = "http://rubygems.org/gems/radiant-vhost-extension"
  s.summary     = %q{Host multiple sites in Radiant CMS}
  s.description = %q{Host multiple sites in Radiant CMS}

  s.rubyforge_project = "radiant-vhost-extension"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
