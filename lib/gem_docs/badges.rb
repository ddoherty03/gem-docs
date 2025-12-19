# frozen_string_literal: true

module GemDocs
  module Badges
    extend self

    README = "README.org"

    Badge = Struct.new(:name, :marker, :org_block, keyword_init: true)

    # ---------- public API ----------

    def ensure_all!
      ensure_github_actions!
      # ensure_rubygems_version!
      # ensure_docs_badge!
    end

    def ensure_github_actions!
      repo = Repo.from_gemspec
      binding.break
      workflow = discover_workflow or return false

      badge = github_actions_badge(repo, workflow)
      ensure_badge!(badge)
    end

    # ---------- badge definitions ----------

    def github_actions_badge(repo, workflow)
      Badge.new(
        name:   "GitHub Actions",
        marker: "actions/workflows/#{workflow}",
        org_block: <<~ORG,
          #+BEGIN_EXPORT markdown
          [![CI](https://github.com/#{repo.user}/actions/workflows/#{workflow}/badge.svg)](
          https://github.com/#{repo.user}/actions/workflows/#{workflow}
          )
          #+END_EXPORT
        ORG
      )
    end

    # ---------- insertion logic ----------

    def ensure_badge!(badge)
      content = File.read(README)

      return false if content.include?(badge.marker)

      updated = insert_after_title(content, badge.org_block)
      File.write(README, updated)
      true
    end

    def insert_after_title(content, block)
      lines = content.lines

      idx =
        lines.index { |l| l.start_with?("#+TITLE:") } ||
        lines.index { |l| l.match?(/\A\*+\s+/) } ||
        0

      lines.insert(idx + 1, "\n", block, "\n")
      lines.join
    end

    def discover_workflow
      dir = ".github/workflows"
      return unless Dir.exist?(dir)

      workflows =
        Dir.children(dir)
          .select { |f| f.match?(/\A.+\.ya?ml\z/) }
          .sort

      return if workflows.empty?

      workflows.find { |f| f =~ /\Aci\.ya?ml\z/i } || workflows.first
    end
  end
end
