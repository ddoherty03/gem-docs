# frozen_string_literal: true

module GemDocs
  RSpec.describe Repo do
    let(:gem_name) { 'fake_gem_' }
    let(:fake_spec) do
      <<~RUBY
        Gem::Specification.new do |spec|
          spec.name        = "#{gem_name}"
          spec.version     = "0.9.10"
          spec.summary     = "Fakes as a first-class data type"
          spec.authors     = ["Bruce Wayne"]

          spec.metadata = {
            #{metadata}
          }
        end
      RUBY
    end

    around do |example|
      Dir.mktmpdir do |dir|
        root = dir
        Dir.chdir(root) do
          File.write(File.join(root, "#{gem_name}.gemspec"), fake_spec)
          workflows_dir = File.join(root, ".github/workflows")
          FileUtils.mkdir_p(workflows_dir)
          File.write(File.join(workflows_dir, "xxx.yml"), "name: XXX")

          example.run
        end
      end
    end

    describe ".from_gemspec" do
      context "when only github source_code_uri is present" do
        # NB: we have to reset the gem name here because
        # Gem::Specification.load will load a cached version of the file from
        # prior examples.
        let(:gem_name) { 'fake_gem_A' }
        let(:metadata) do
          <<~META
            "source_code_uri" => "https://github.com/bwayne/#{gem_name}",
          META
        end

        it "extracts user and repo from source_code_uri" do
          repo = Repo.from_gemspec

          expect(repo.host).to eq("github.com")
          expect(repo.user).to eq("bwayne")
          expect(repo.name).to eq("fake_gem_A")
        end
      end

      context "when only gitlab source_code_uri is present" do
        let(:gem_name) { 'fake_gem_B' }
        let(:metadata) do
          <<~META
            "source_code_uri" => "https://gitlab.com/bwayne/#{gem_name}",
          META
        end

        it "extracts user and repo from source_code_uri" do
          repo = Repo.from_gemspec

          expect(repo.host).to eq("gitlab.com")
          expect(repo.user).to eq("bwayne")
          expect(repo.name).to eq("fake_gem_B")
        end
      end

      context "when only homepage_uri is present" do
        let(:gem_name) { 'fake_gem_C' }
        let(:metadata) do
          <<~META
            "homepage_uri" => "https://github.com/bwayne/#{gem_name}"
          META
        end

        it "falls back to homepage_uri" do
          repo = Repo.from_gemspec

          expect(repo.user).to eq("bwayne")
          expect(repo.name).to eq("fake_gem_C")
        end
      end

      context "when URL ends with .git" do
        let(:gem_name) { 'fake_gem_D' }
        let(:metadata) do
          <<~META
            "source_code_uri" => "https://github.com/ded/#{gem_name}.git"
          META
        end

        it "strips the .git suffix" do
          repo = Repo.from_gemspec

          expect(repo.name).to eq("fake_gem_D")
        end
      end

      context "when using SSH GitHub URL" do
        let(:gem_name) { 'fake_gem_E' }
        let(:metadata) do
          <<~META
            "source_code_uri" => "https://github.com/bwayne/#{gem_name}.git",
          META
        end

        it "parses SSH URLs" do
          repo = Repo.from_gemspec

          expect(repo.user).to eq("bwayne")
          expect(repo.name).to eq("fake_gem_E")
        end
      end

      context "when no repository URL is available" do
        let(:gem_name) { 'fake_gem_F' }
        let(:metadata) { '' }

        it "aborts with a helpful message" do
          expect {
            Repo.from_gemspec
          }.to raise_error(SystemExit, /No repository URL found/)
        end
      end

      context "when URL is not a GitHub URL" do
        let(:gem_name) { 'fake_gem_G' }
        let(:metadata) do
          <<~META
            "source_code_uri" => "https://example.com/foo/bar"
          META
        end

        it "aborts with an unsupported URL message" do
          expect {
            Repo.from_gemspec
          }.to raise_error(SystemExit, /Unsupported repository URL/)
        end
      end
    end
  end
end
