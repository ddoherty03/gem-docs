# frozen_string_literal: true

module GemDocs
  class Repo
    attr_accessor :root, :host, :user, :name, :module_name
    attr_accessor  :branch, :workflow_dir, :workflow_name

    def initialize(root: nil, host: nil,
                   user: nil,
                   name: nil,
                   module_name: nil,
                   branch: 'master',
                   workflow_dir: nil,
                   workflow_name: nil
                  )
      @root = root
      @host = host
      @user = user
      @module_name = module_name
      @name = name
      @branch = branch
      @workflow_dir = workflow_dir
      @workflow_name = workflow_name
    end

    def workflow
      workflow_name.to_s
    end

    class << self
      def from_gemspec
        spec = load_gemspec(gemspec_path)

        url =
          spec.metadata["source_code_uri"] ||
          spec.metadata["homepage_uri"] ||
          spec.homepage

        abort "No repository URL found in gemspec metadata" unless url

        # root = File.dirname(File.expand_path(path))
        root = GemDocs.project_root
        meta = parse_url(url)
        name = GemDocs.config.repo_name ||
               spec.name ||
               meta[:name] ||
               File.basename(Dir['*.gemspec'].first) ||
               File.basename(root)
        host = GemDocs.config.repo_host ||
               meta[:host]
        user = GemDocs.config.repo_user ||
               meta[:user]
        mname = to_module(name)
        branch = GemDocs.config.repo_branch ||
                 repo_default_branch(root:)
        wdir, wname = workflow_dir_name
        new(
          root: root,
          host: host,
          user: user,
          name: name,
          module_name: mname,
          branch: branch,
          workflow_dir: wdir,
          workflow_name: wname,
        )
      end

      def workflow_dir_name
        if GemDocs.config.repo_workflow_name && GemDocs.config.repo_workflow_dir
          workflow_file = File.join(
            GemDocs.project_root,
            GemDocs.config.repo_workflow_dir,
            GemDocs.config.repo_workflow_name,
          )
          return [File.dirname(workflow_file), File.dirname(workflow_file)] if File.readable?(workflow_file)
        end

        dir = File.join(GemDocs.project_root, ".github/workflows")
        return unless Dir.exist?(dir)

        workflows =
          Dir.children(dir)
            .select { |f| f.match?(/\A.+\.ya?ml\z/) }
            .sort
        return if workflows.empty?

        fname = workflows.find { |f| f =~ /\A[A-Za-z][^\.]*\.ya?ml\z/i } || workflows.first
        # File.join(dir, fname)
        [dir, fname]
      end

      def to_module(name)
        name.split(/[-_]/).map(&:capitalize).join('')
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
        candidates = nil
        Dir.chdir(GemDocs.project_root) do
          candidates = Dir["*.gemspec"]
          abort "No gemspec found" if candidates.empty?
          abort "Multiple gemspecs found: #{candidates.join(', ')}" if candidates.size > 1
        end
        candidates.first
      end

      def load_gemspec(path)
        Gem::Specification.load(path) ||
          abort("Failed to load gemspec: #{path}")
      end
    end
  end
end
