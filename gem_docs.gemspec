# frozen_string_literal: true

require_relative "lib/gem_docs/version"

Gem::Specification.new do |spec|
  spec.name = "gem_docs"
  spec.version = GemDocs::VERSION
  spec.authors = ["Daniel E. Doherty"]
  spec.email = ["ded@ddoherty.net"]
  spec.summary       = "Documentation automation for Ruby gems"
  spec.description   = "Shared tasks for README.org execution, GFM export, YARD integration (future), etc."
  spec.homepage = "https://github.com/ddoherty03/gem_docs"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ddoherty03/gem_docs"
  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "rake"
  spec.add_dependency "yard", "~> 0.9"
end
