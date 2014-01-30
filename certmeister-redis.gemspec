# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'certmeister/version'

Gem::Specification.new do |spec|
  spec.name          = "certmeister-redis"
  spec.version       = Certmeister::VERSION
  spec.authors       = ["Sheldon Hearn"]
  spec.email         = ["sheldonh@starjuice.net"]
  spec.summary       = %q{Redis store for certmeister}
  spec.description   = %q{This gem provides a redis store for use in certmeister, the conditional autosigning certificate authority.}
  spec.homepage      = "https://github.com/sheldonh/certmeister"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z lib/certmeister spec/certmeister`.split("\x0").grep(/redis/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "certmeister", Certmeister::VERSION
  spec.add_dependency "redis-sentinel", "~> 1.4"
end
