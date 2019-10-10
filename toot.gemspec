# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toot/version'

Gem::Specification.new do |spec|
  spec.name          = "toot"
  spec.version       = Toot::VERSION
  spec.authors       = ["Travis Petticrew"]
  spec.email         = ["travis@petticrew.net"]

  spec.summary       = %q{Send and receive events from remote services over HTTP.}
  spec.description   = %q{Send and receive events from remote services over HTTP.}
  spec.homepage      = "https://github.com/watermarkchurch/toot"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sidekiq", ">=2"
  spec.add_dependency "rack", ">=1"
  spec.add_dependency "faraday", "<1"
  spec.add_dependency "activesupport"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
end
