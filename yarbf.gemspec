# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yarbf/version'

Gem::Specification.new do |s|
  s.name          = 'yarbf'
  s.version       = Yarbf::VERSION
  s.authors       = ['Chaos Shen']
  s.email         = ['chaosdefinition@hotmail.com']

  s.summary       = 'Yet another Brainfuck interpreter in Ruby'
  s.description   = 'yarbf is a simple Brainfuck interpreter in Ruby.'
  s.homepage      = 'http://github.com/chaosdefinition/yarbf'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir        = 'bin'
  s.executables   = ['yarbf']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.0.0'

  # runtime dependencies
  s.add_runtime_dependency 'io-console', '~> 0.4'
end
