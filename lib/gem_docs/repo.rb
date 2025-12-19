# frozen_string_literal: true

module GemDocs
  class Repo
    attr_accessor :root, :host, :user, :name, :branch

    def initialize(root: nil, host: nil, user: nil, name: nil, branch: 'master')
      @root = root
      @host = host
      @user = user
      @name = name
      @branch = branch
    end

    class << self
      def from_gemspec(path = gemspec_path)
        spec = load_gemspec(path)

        url =
          spec.metadata["source_code_uri"] ||
          spec.metadata["homepage_uri"] ||
          spec.homepage

        abort "No repository URL found in gemspec metadata" unless url

        root = File.dirname(File.expand_path(path))
        meta = parse_url(url)
        name = spec.name || meta[:name]
        branch = repo_default_branch(root:)
        new(
          root: root,
          host: meta[:host],
          user: meta[:user],
          name: name,
          branch: branch,
        )
      end

      private

      def repo_default_branch(root:)
        return "master" unless git_repo?(root:)

        default_branch_from_origin ||
          fallback_branch ||
          "master"
      end

      def fallback_branch
        return unless git_available?

        branches = %x[git branch --list 2>/dev/null]
                     .lines
                     .map { |l| l.sub("*", "").strip }

        return "master" if branches.include?("master")
        return "main"   if branches.include?("main")

        nil
      end

      def default_branch_from_origin
        return unless git_available?

        ref = %x[git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null].strip
        return if ref.empty?

        ref.split("/").last
      end

      def git_available?
        system("git", "--version", out: File::NULL, err: File::NULL)
      end

      def git_repo?(root: nil)
        File.directory?(File.join(root, ".git"))
      end

      # Return {host: <git_host>, user: <user_name>, name: <repo_name> } by parsing the given url
      def parse_url(url)
        host_bases = ['github', 'gitlab']
        md = url.match(%r{(?<host>(?:#{host_bases.join('|')})\.com)/(?<user>[^/]+)/(?<repo_name>[^/]+)(?:\.git)?/?})
        abort "Unsupported repository URL: #{url}" unless md

        { host: md[:host], user: md[:user], name: md[:repo_name] }
      end

      def gemspec_path
        candidates = Dir["*.gemspec"]
        abort "No gemspec found" if candidates.empty?
        abort "Multiple gemspecs found: #{candidates.join(', ')}" if candidates.size > 1
        candidates.first
      end

      def load_gemspec(path)
        Gem::Specification.load(path) ||
          abort("Failed to load gemspec: #{path}")
      end
    end
  end
end
