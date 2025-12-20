# frozen_string_literal: true

module GemDocs
  module Badges
    extend self

    README = "README.org"

    Badge = Struct.new(:name, :marker, :org_block, keyword_init: true)

    def ensure!
      repo = Repo.from_gemspec
      workflow = discover_workflow or return false
      badge = make_badge(repo, workflow)
      ensure_badge!(badge)
    end

    private

    # Create a Badge struct using the given repo and workflow name.
    def make_badge(repo, workflow)
      if repo.host.match?(/github/i)
        Badge.new(
          name:   'GitHub Actions',
          marker: '#badge',
          org_block: <<~ORG,
            #+BEGIN_EXPORT markdown
              [![CI](https://github.com/#{repo.user}/#{repo.name}/actions/workflows/#{workflow}/badge.svg)](https://github.com/#{repo.user}/#{repo.name}/actions/workflows/#{workflow})
            #+END_EXPORT
          ORG
        )
      elsif repo.host.match?(/gitlab/i)
        Badge.new(
          name:   "GitLab CI",
          marker: "#badge gitlab",
          org_block: <<~ORG,
            #+BEGIN_EXPORT markdown
            [![pipeline status](https://gitlab.com/#{repo.user}/badges/#{branch}/pipeline.svg)](
            https://gitlab.com/#{repo.user}/-/pipelines
            )
            #+END_EXPORT
          ORG
        )
      end
    end

    # Write the badge block to the README unless it's already there.  Replace
    # the #badge marker if present, otherwise add after TITLE.
    def ensure_badge!(badge)
      content = File.read(README)
      updated =
        if content.lines.find { |l| l.match?(/\A\s*#{Regexp.quote(badge.marker)}/) }
          insert_at_marker(badge.marker, content, badge.org_block)
        elsif content.include?(badge.org_block)
          # Do nothing and return nil to indicate badge present
          return
        else
          insert_after_header(content, badge.org_block)
        end

      File.write(README, updated)
    end

    # Insert the badge block after the org header lines, if any.  If there are
    # no header lines, insert at the beginning of the file.
    def insert_after_header(content, block)
      lines = content.lines
      out_lines = +''

      in_header = lines.any? { |l| l.match?(/\A\s*\#\+/) }
      block_added = false
      lines.each do |line|
        out_lines <<
          if in_header && line.match?(/\A\s*\#\+/)
            line
          elsif in_header && !line.match?(/\A\s*\#\+/)
            in_header = false
            block_added = true
            if line.match?(/\A\s*\z/)
              line + block
            else
              "\n" + block + "\n" + line
            end
          elsif !in_header && !block_added
            block_added = true
            block + "\n\n" + line
          else
            line
          end
      end
      out_lines
    end

    def insert_at_marker(marker, content, block)
      lines = content.lines
      out_lines = +''

      lines.each do |line|
        out_lines <<
          if line.match?(/^#{marker}/)
            block
          else
            line
          end
      end
      out_lines
    end

    def discover_workflow
      dir = ".github/workflows"
      return unless Dir.exist?(dir)

      workflows =
        Dir.children(dir)
          .select { |f| f.match?(/\A.+\.ya?ml\z/) }
          .sort
      return if workflows.empty?

      workflows.find { |f| f =~ /\A[A-Za-z][^\.]*\.ya?ml\z/i } || workflows.first
    end
  end
end
