# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uamir/version'

Gem::Specification.new do |spec|
  spec.name          = "uamir"
  spec.version       = UAMiR::VERSION
  spec.authors       = ["Christopher Hunt"]
  spec.email         = ["chrahunt@gmail.com"]
  spec.summary       = %q{This gem provides a programmatic interface to the Universal Assignment Manager associated with API Healthcare's Contingent Staffing/Recruiting Solution.}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  #spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "httparty", "~> 0.13.1"
  spec.add_runtime_dependency "json", "~> 1.8.1"
end
