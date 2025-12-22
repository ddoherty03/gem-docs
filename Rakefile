# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

require_relative "lib/gem_docs"
GemDocs.install
GemDocs.configure do |c|
  c.overview_headings = ["Overview", "Usage"]
end

task default: %i[spec rubocop]
