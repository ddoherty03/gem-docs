# frozen_string_literal: true

module GemDocs
  class Config
    attr_accessor :overview_markers      # [start, end]
    attr_accessor :overview_headings     # ["Intro", "Overview"]

    def initialize
      # Default: support org comment markers
      @overview_markers  = ["# gem-docs:overview:start", "# gem-docs:overview:end"]
      @overview_headings = ["Overview", "Introduction", "Summary"]
    end
  end

  def self.configure
    yield(config)
  end

  def self.config
    @config ||= Config.new
  end
end
