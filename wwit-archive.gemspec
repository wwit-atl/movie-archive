# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wwit/archive/globals'

Gem::Specification.new do |spec|
  spec.name          = 'wwit-archive'
  spec.version       = WWIT::Archive::VERSION
  spec.authors       = [ WWIT::Archive::AUTHOR ]
  spec.email         = [ WWIT::Archive::AEMAIL ]
  spec.summary       = WWIT::Archive::SUMMARY
  spec.description   = WWIT::Archive::DESCRIPTION
  spec.homepage      = WWIT::Archive::HOMEPAGE
  spec.license       = WWIT::Archive::LICENSE

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters'
end
