require 'rubygems'
require 'spec/rake/spectask'
require "synthesis/task"
require 'cucumber/rake/task'
  
desc "Run Rspec and Cucumber features"
task :default do |t|
  Rake::Task['spec'].invoke
  # Rake::Task['test:features'].invoke
end

desc "Run RSpec tests"
Spec::Rake::SpecTask.new("spec") do |t|
  t.pattern = 'spec/unit/*_spec.rb'
end

desc "Run Rspec tests with rcov"
Spec::Rake::SpecTask.new("spec:rcov") do |t|
  t.rcov = true
  t.pattern = 'spec/unit/*_spec.rb'
  t.rcov_opts = ['--exclude', '\/Library\/Ruby', '--exclude', 'spec' ]
end

Synthesis::Task.new("spec:synthesis") do |t|
  t.adapter = :rspec
  t.pattern = 'spec/**/*_spec.rb'
end

desc "Run Cucumber features"
Cucumber::Rake::Task.new("features") do |t|
end