# frozen_string_literal: true

module GemDocs
  class Config
    attr_accessor :overview_headings
    attr_accessor :headers
    attr_accessor :repo_host
    attr_accessor :repo_name
    attr_accessor :repo_user
    attr_accessor :repo_branch
    attr_accessor :repo_workflow_dir
    attr_accessor :repo_workflow_name
    attr_accessor :badge

    def initialize
      # Default: support org comment markers
      @overview_headings = ["Introduction"]
      @headers =
        <<~HEADER
          #+PROPERTY: header-args:ruby :results value :colnames no :hlines yes :exports both :dir "./"
          #+PROPERTY: header-args:ruby+ :wrap example :session %n_session :eval yes
          #+PROPERTY: header-args:ruby+ :prologue "$:.unshift('./lib') unless $:.first == './lib'; require '%n'"
          #+PROPERTY: header-args:sh :exports code :eval no
          #+PROPERTY: header-args:bash :exports code :eval no
        HEADER
      @repo_host = nil
      @repo_name = nil
      @repo_user = nil
      @repo_branch = nil
      @repo_workflow_dir = ".github/workflows"
      @repo_workflow_name = nil
      @badge =
        <<~BADGE
          #+BEGIN_EXPORT markdown
          [![CI](https://github.com/%u/%n/actions/workflows/%w/badge.svg?branch=%b)](https://github.com/%u/%n/actions/workflows/%w)
          #+END_EXPORT
        BADGE
    end
  end

  def self.configure
    yield(config)
  end

  def self.config
    @config ||= Config.new
  end
end
