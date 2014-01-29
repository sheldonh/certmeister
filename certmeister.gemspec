# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'certmeister/version'

Gem::Specification.new do |spec|
  spec.name          = "certmeister"
  spec.version       = Certmeister::VERSION
  spec.authors       = ["Sheldon Hearn"]
  spec.email         = ["sheldonh@starjuice.net"]
  spec.summary       = %q{Conditionally autosigning certificate authority.}
  spec.description   = %q{Certificate authority that can be configured to make decisions about whether to autosign certificate signing requests for clients. This gem provides the protocol-agnostic library, which is expected to be used within something like an HTTP REST service.}
  spec.homepage      = "https://github.com/sheldonh/certmeister"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 0"
  spec.add_development_dependency "rspec", "~> 2.14"
end


