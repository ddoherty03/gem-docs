# frozen_string_literal: true

module GemDocs
  module Header
    PROPERTY_RE = /^#\+PROPERTY:\s+header-args:ruby/

    # @return String The overview from README per config
    def self.write_header?
      return false if present?

      prelim, body = extract_prelim_body
      new_org = prelim.join.strip + org_headers.strip + "\n\n" + body.join
      File.write(README_ORG, new_org) > 0
    end

    def self.present?
      prelim = extract_prelim_body.first
      prelim.any? { |h| h.match?(PROPERTY_RE) }
    end

    class << self
      private

      # Returns the preliminary comment, blank, and header lines from README.org
      def extract_prelim_body
        prelim = []
        body = []
        in_prelim = true
        File.read(README_ORG).lines.each do |line|
          if in_prelim && line.match?(/^\s*[^#\n]+\s*$/)
            in_prelim = false
            body << line
          elsif in_prelim && (line.match(/^#/) || line.match(/^\s*$/))
            prelim << line
          # elsif in_prelim
          #   in_prelim = false
          #   body << line
          else
            body << line
          end
        end
        [prelim, body]
      end

      def org_headers
        repo = Repo.from_gemspec
        GemDocs.config.headers
          .gsub('%n', repo.name)
          .gsub('%h', repo.host)
          .gsub('%u', repo.user)
          .gsub('%r', repo.root)
          .gsub('%b', repo.branch)
          .gsub('%w', repo.workflow)
      end
    end
  end
end
