# frozen_string_literal: true

module GemDocs
  module Skeleton
    # @return String The overview from README per config
    def self.make_readme?
      return false if readme_present?

      repo = Repo.from_gemspec
      content = <<~SKEL
        #+TITLE: #{repo.module_name} Guide

        * Introduction

        * Installation

        #+begin_src sh :eval no
          bundle add #{repo.name}
        #+end_src

        If bundler is not being used to manage dependencies, install the gem by executing:

        #+begin_src sh :eval no
          gem install #{repo.name}
        #+end_src

        * Usage

        * Development
        After checking out the repo, run `bin/setup` to install dependencies. Then,
        run `rake spec` to run the tests. You can also run `bin/console` for an
        interactive prompt that will allow you to experiment.

        To install this gem onto your local machine, run `bundle exec rake
        install`.

        * Contributing
        Bug reports and pull requests are welcome on GitHub at
        https://github.com/#{repo.user}/#{repo.name}.

        * License
        The gem is available as open source under the terms of the [MIT
        License](https://opensource.org/licenses/MIT).
      SKEL
      File.write(README_ORG, content) > 0
    end

    def self.readme_present?
      File.exist?(README_ORG)
    end

    def self.make_changelog?
      return false if changelog_present?

      content = <<~SKEL
        * COMMENT CHANGELOG tips:
        1. Don't dump your git change logs into this file, write them yourself.
        2. Keep entries short and user-focused,
        3. Use non-technical language, but do speak in the vocabulary of your gem.
        4. Don't document changes only of interest to the programmers, just those the
           user would find useful.
        5. Give each heading a version number and an inactive date (C-c ! is useful here).

        * Version 0.3.0 [2025-12-27 Sat]
        - First change
        - Second change
      SKEL
      File.write(CHANGELOG_ORG, content) > 0
    end

    def self.changelog_present?
      File.exist?(CHANGELOG_ORG)
    end
  end
end
