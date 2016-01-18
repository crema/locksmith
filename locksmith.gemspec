# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'locksmith/version'

Gem::Specification.new do |spec|
  spec.name          = 'locksmith'
  spec.version       = Locksmith::VERSION
  spec.authors       = ['whonz']
  spec.email         = ['whonzmail@gmail.com']

  spec.summary       = 'active record deadlock detector'
  spec.description   = 'MySQL record lock base deadlock detector'
  spec.homepage      = 'https://github.com/cremame/locksmith'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord', '~> 4.2.4'
  spec.add_runtime_dependency 'activesupport', '~> 4.2.4'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
end
