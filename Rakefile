require 'bundler/gem_tasks'

# test task
require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

task :default => :spec
task :spec => :test
