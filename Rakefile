# froze_string_literal: true

require "bundler/gem_tasks"

require "rake/testtask"

desc "Run unit tests"
task default: :test

desc "Test BetterRateLimit"
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end
