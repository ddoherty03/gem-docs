# frozen_string_literal: true

ruby '>= 3.2.9', '<= 4.0.0'

source "https://rubygems.org"

# Specify your gem's dependencies in gem_docs.gemspec
gemspec

group :development do
  # rubocop and the shared config gem:
  gem 'rubocop', require: false
  gem 'rubocop-ddoherty', git: 'https://github.com/ddoherty03/rubocop-ddoherty.git', branch: 'master', require: false
  gem 'debug', '>= 1.0.0'
  gem "irb"
  gem 'pry'
  gem 'pry-doc'
  gem 'pry-byebug'
  gem "rake", "~> 13.0"
  gem "rspec", "~> 3.0"
  gem 'simplecov'
end
