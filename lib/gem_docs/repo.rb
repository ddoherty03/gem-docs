# frozen_string_literal: true

module GemDocs
  class Repo
    attr_accessor :root, :user, :name

    def initialize(root: nil, user: nil, name: nil)
      @root = root
      @user = user
      @name = name
    end

    class << self
      def from_gemspec(path = gemspec_path)
        spec = load_gemspec(path)

        url =
          spec.metadata["source_code_uri"] ||
          spec.metadata["homepage_uri"] ||
          spec.homepage

        abort "No repository URL found in gemspec metadata" unless url

        meta = parse_url(url)
        new(root: File.dirname(File.expand_path(path)), user: meta[:user], name: meta[:name])
      end

      private

      def parse_url(url)
        raise NotImplemented, "define .parse_url in subclass of Repo"
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

  class GitHubRepo < Repo
    # Return {user: <user_name>, name: <repo_name> } by parsing the given url
    def self.parse_url(url)
      uri = url.strip

      # Accept:
      # https://github.com/user/repo
      # https://github.com/user/repo.git
      # git@github.com:user/repo.git
      case uri
      when %r{\Ahttps://github\.com/([^/]+)/([^/]+?)(?:\.git)?/?\z}
        { user: Regexp.last_match(1), name: Regexp.last_match(2) }
      when %r{\Agit@github\.com:([^/]+)/([^/]+?)(?:\.git)?\z}
        { user: Regexp.last_match(1), name: Regexp.last_match(2) }
      else
        abort "Unsupported repository URL: #{url}"
      end
    end
  end
end
