require "bundler/gem_tasks"
require "rake/testtask"

task :test => ["test:units"]

namespace :test do
  Rake::TestTask.new(:units) do |task|
    task.libs << "test"
    task.test_files = FileList["test/unit/**/*_test.rb"]
  end
end
