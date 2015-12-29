lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'yarbf'

Gem::Specification.new do |s|
  # required attributes
  s.authors     = ['Chaos Shen']
  s.files       = ['lib/yarbf.rb']
  s.name        = 'yarbf'
  s.version     = Yarbf::VERSION
  s.summary     = 'Yet another Brainfuck interpreter in Ruby'

  # recommended attributes
  s.email       = 'chaosdefinition@hotmail.com'
  s.homepage    = 'http://github.com/chaosdefinition/yarbf'
  s.licenses    = ['MIT']

  # optional attributes
  s.executables << 'yarbf'
  s.description = 'yarbf is a simple Brainfuck interpreter in Ruby.'

  # dependencies
  s.add_runtime_dependency 'io-console', '~> 0.4'
end
