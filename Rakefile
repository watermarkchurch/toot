# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :environment do
  $LOAD_PATH.unshift File.expand_path('lib', __dir__)
  require 'toot'
end

load './lib/tasks/toot.rake'
