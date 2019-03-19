require "rake/testtask"

task default: :test

desc "Run tests"
Rake::TestTask.new do |t|
  t.libs << "."
  t.libs << "test"
  t.test_files = Dir["test/**/test_*.rb"]
end
