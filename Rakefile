require 'rubygems'
require 'spec/rake/spectask'
require "synthesis/task"

task :default => ["test:spec"]

desc "Run RSpec tests"
Spec::Rake::SpecTask.new("test:spec") do |t|
  t.pattern = 'spec/unit/*_spec.rb'
end

Synthesis::Task.new("test:synthesis") do |t|
  t.adapter = :rspec
  t.pattern = 'spec/**/*_spec.rb'
end
