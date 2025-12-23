# frozen_string_literal: true

module GemDocs
  module Badge
    GITHUB_BADGE_RE = %r{actions/workflows.*badge.svg}
    GITLAB_BADGE_RE = %r{badges/.*pipeline.svg}

    Badge = Struct.new(:name, :marker, :org_block, keyword_init: true)

    def self.ensure!
      repo = Repo.from_gemspec
      return false if repo.workflow.to_s.match?(/\A\s*\z/)

      badge = make_badge(repo)
      ensure_badge!(badge, repo)
    end

    class << self
      private

      def make_badge(repo)
        repo = Repo.from_gemspec
        org_block =
          GemDocs.config.badge
            .gsub('%n', repo.name)
            .gsub('%h', repo.host)
            .gsub('%u', repo.user)
            .gsub('%r', repo.root)
            .gsub('%b', repo.branch)
            .gsub('%w', repo.workflow)
        Badge.new(
          name:   'GitHub Actions',
          marker: '#badge',
          org_block: org_block,
        )
      end

      # Write the badge block to the README unless it's already there.  Replace
      # the #badge marker if present, otherwise add after TITLE.
      def ensure_badge!(badge, repo)
        content = File.read(README_ORG)
        updated =
          if content.lines.find { |l| l.match?(/\A\s*#{Regexp.quote(badge.marker)}/) }
            insert_at_marker(badge.marker, content, badge.org_block)
          elsif (repo.host.include?('github') && content.match?(GITHUB_BADGE_RE)) ||
                (repo.host.include?('gitlab') && content.match?(GITLAB_BADGE_RE))
            # Do nothing and return nil to indicate badge present
            return
          else
            insert_after_header(content, badge.org_block)
          end

        File.write(README_ORG, updated)
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
                line + block + "\n\n"
              else
                "\n" + block + "\n\n" + line
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
    end
  end
end
