# frozen_string_literal: true

module GemDocs
  module Skeleton
    PROPERTY_RE = /^#\+PROPERTY:\s+header-args:ruby/

    # @return String The overview from README per config
    def self.make_readme?
      return false if present?

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

    def self.present?
      File.exist?(README_ORG)
    end
  end
end
