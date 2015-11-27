# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'moon_rabbit/version'

Gem::Specification.new do |spec|
  spec.name          = "moon_rabbit"
  spec.version       = MoonRabbit::VERSION
  spec.authors       = ["liveralmask"]
  spec.email         = ["liveralmask.lisk@gmail.com"]
  spec.summary       = %q{Briefly build scripts.}
  spec.description   = %q{Briefly build scripts.}
  spec.homepage      = "https://github.com/liveralmask/moon_rabbit"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 0"
end
