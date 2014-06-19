# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wwit/archive/version'

Gem::Specification.new do |spec|
  spec.name          = 'wwit-archive'
  spec.version       = WWIT::Archive::VERSION
  spec.authors       = ['Donovan C. Young']
  spec.email         = ['dyoung522@gmail.com']
  spec.summary       = %q{Archives WWIT Show files to RAID and S3}
  spec.description   = %q{Provides a runtime binary which can be called from CLI or cron to archive movie files.}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'getoptions'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
end
