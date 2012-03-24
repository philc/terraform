# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "terraform/version"

Gem::Specification.new do |s|
  s.name        = "terraform"
  s.version     = Terraform::VERSION
  s.authors     = ["Phil Crosby"]
  s.email       = ["phil.crosby@gmail.com"]
  s.homepage    = "http://github.com/philc/terraform"
  s.summary     = %q{Set up a cold, inhospitable system using Terraform.}
  # s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "terraform"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
