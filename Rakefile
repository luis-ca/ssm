begin
  require 'spec/rake/spectask'

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
rescue LoadError
  desc 'spec rake task not available'
  task :spec do
    abort 'Rspec rake task is not available. Be sure to install Rspec as a gem'
  end
end

begin
  require "synthesis/task"

  desc "Run Synthesis on specs"
  Synthesis::Task.new("spec:synthesis") do |t|
    t.adapter = :rspec
    t.pattern = 'spec/**/*_spec.rb'
  end
rescue LoadError
  desc 'Synthesis rake task not available'
  task "spec:synthesis" do
    abort 'Synthesis rake task is not available. Be sure to install synthesis as a gem'
  end
end

begin
  require 'cucumber/rake/task'

  desc "Run Cucumber features"
  Cucumber::Rake::Task.new("features") do |t|
    t.fork = true
    t.cucumber_opts = %w{--format pretty}
  end
rescue LoadError
  desc 'Cucumber rake task not available'
  task :features do
    abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem'
  end
end

desc "Run Rspec and Cucumber features"
task :default => :spec #['spec', 'features']