# encoding: utf-8

require 'rubygems'
require 'rake'

begin
  gem 'ore-tasks', '~> 0.4'
  require 'ore/tasks'

  Ore::Tasks.new
rescue LoadError => e
  warn e.message
  warn "Run `gem install ore-tasks` to install 'ore/tasks'."
end

begin
  gem 'rspec', '~> 2.4'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new
rescue LoadError => e
  task :spec do
    abort "Please run `gem install rspec` to install RSpec."
  end
end

task :test => :spec
task :default => :spec

begin
  gem 'yard', '~> 0.7'
  require 'yard'

  YARD::Rake::YardocTask.new  
rescue LoadError => e
  task :yard do
    abort "Please run `gem install yard` to install YARD."
  end
end
task :doc => :yard
