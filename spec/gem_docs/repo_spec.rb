# frozen_string_literal: true

module GemDocs
  RSpec.describe Repo do
    let(:fake_spec) do
      <<~RUBY
        Gem::Specification.new do |spec|
          spec.name        = "fake_gem"
          spec.version     = "0.9.10"
          spec.summary     = "Fakes as a first-class data type"
          spec.authors     = ["Bruce Wayne"]

          spec.metadata = {
            #{metadata}
          }
        end
      RUBY
    end

    let(:gem_name) { 'fake_gem' }

    around do |example|
      Dir.mktmpdir do |dir|
        @root = dir
        Dir.chdir(@root) do
          File.write(File.join(@root, "#{gem_name}.gemspec"), fake_spec)
          workflows_dir = File.join(@root, ".github/workflows")
          FileUtils.mkdir_p(workflows_dir)
          File.write(File.join(workflows_dir, "xxx.yml"), "name: XXX")

          example.run
        end
      end
    end

    describe ".from_gemspec" do
      context "when only source_code_uri is present" do
        let(:metadata) do
          <<~META
            "source_code_uri" => "https://github.com/bwayne/fake_gem",
          META
        end

        it "extracts user and repo from source_code_uri" do
          repo = GitHubRepo.from_gemspec

          expect(repo.user).to eq("bwayne")
          expect(repo.name).to eq("fake_gem")
        end
      end

      context "when only homepage_uri is present" do
        let(:metadata) do
          <<~META
            "homepage_uri" => "https://github.com/bwayne/fake_gem"
          META
        end

        it "falls back to homepage_uri" do
          repo = GitHubRepo.from_gemspec

          expect(repo.user).to eq("bwayne")
          expect(repo.name).to eq("fake_gem")
        end
      end

      context "when URL ends with .git" do
        let(:metadata) do
          <<~META
            "source_code_uri" => "https://github.com/ded/fake_gem.git"
          META
        end

        it "strips the .git suffix" do
          repo = GitHubRepo.from_gemspec

          expect(repo.name).to eq("fake_gem")
        end
      end

      context "when using SSH GitHub URL" do
        let(:metadata) do
          <<~META
            "source_code_uri" => "https://github.com/bwayne/fake_gem.git",
          META
        end

        it "parses SSH URLs" do
          repo = GitHubRepo.from_gemspec

          expect(repo.user).to eq("bwayne")
          expect(repo.name).to eq("fake_gem")
        end
      end

      context "when no repository URL is available" do
        # NB: we have to reset the gem name here because
        # Gem::Specification.load will load a cached version of the file from
        # prior examples.
        let(:gem_name) { 'fake_gem2' }
        let(:metadata) { '' }

        it "aborts with a helpful message" do
          expect {
            GitHubRepo.from_gemspec
          }.to raise_error(SystemExit, /No repository URL found/)
        end
      end

      context "when URL is not a GitHub URL" do
        # NB: we have to reset the gem name here because
        # Gem::Specification.load will load a cached version of the file from
        # prior examples.
        let(:gem_name) { 'fake_gem3' }
        let(:metadata) do
          <<~META
            "source_code_uri" => "https://example.com/foo/bar"
          META
        end

        it "aborts with an unsupported URL message" do
          expect {
            GitHubRepo.from_gemspec
          }.to raise_error(SystemExit, /Unsupported repository URL/)
        end
      end
    end
  end
end
