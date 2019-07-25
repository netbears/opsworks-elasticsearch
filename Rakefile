# frozen_string_literal: true

# Inspeired by: https://github.com/burtlo/cookbook-raketasks/blob/master/lib/cookbook/raketasks/spec.rb

require 'rake'
require 'rspec/core/rake_task'
require 'dotenv/tasks'
require 'rubocop/rake_task'
require 'kitchen'

module Cookbook
  module Raketasks
    extend Rake::DSL

    desc 'Run all tasks'
    task default: ['rubocop:auto_correct'] # , :spec]

    desc 'Run rubocop'
    RuboCop::RakeTask.new('rubocop')
  end
end
