# frozen_string_literal: true

module GemDocs
  RSpec.describe Badge do
    let(:metadata) do
      <<~SPEC
        "source_code_uri" => "https://github.com/ded/fat_table",
        "changelog_uri" => "https://github.com/ded/fat_table/blob/master/CHANGELOG.md",
      SPEC
    end
    let(:gem_name) { 'fake_gem' }
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

    let(:readme_wo_badge_or_marker) do
      <<~ORG
        #+TITLE: FatTable
        #+PROPERTY: header-args:ruby :results value :colnames no :hlines yes :exports both :dir "./"
        #+PROPERTY: header-args:ruby :wrap example :session fat_fin_session
        #+PROPERTY: header-args:ruby+ :prologue "require_relative 'lib/fat_fin'" :eval yes
        #+PROPERTY: header-args:sh :exports code :eval no
        #+PROPERTY: header-args:bash :exports code :eval no

        * Introduction
        Some text here.
      ORG
    end

    let(:readme_wo_badge_w_marker) do
      <<~ORG
        #+PROPERTY: header-args:ruby :results value :colnames no :hlines yes :exports both :dir "./"
        #+PROPERTY: header-args:ruby :wrap example :session fat_fin_session
        #+PROPERTY: header-args:ruby+ :prologue "require_relative 'lib/fat_fin'" :eval yes
        #+PROPERTY: header-args:sh :exports code :eval no
        #+PROPERTY: header-args:bash :exports code :eval no
        #+TITLE: FatTable

        #badge

        * Introduction
        Some text here.
      ORG
    end

    let(:readme_w_badge) do
      repo = GemDocs::Repo.new(user: 'ded', name: 'fake_gem')
      workflow = 'xxx.yml'
      <<~ORG
        #+TITLE: FatTable
        #+OPTIONS: toc:5
        #+PROPERTY: header-args:ruby :results value :colnames no :hlines yes :exports both :dir "./"
        #+PROPERTY: header-args:ruby :wrap example :session fat_fin_session
        #+PROPERTY: header-args:ruby+ :prologue "require_relative 'lib/fat_fin'" :eval yes
        #+PROPERTY: header-args:sh :exports code :eval no
        #+PROPERTY: header-args:bash :exports code :eval no

        #+BEGIN_EXPORT markdown
          [![CI](https://github.com/#{repo.user}/#{repo.name}/actions/workflows/#{workflow}/badge.svg)](https://github.com/#{repo.user}/#{repo.name}/actions/workflows/#{workflow})
        #+END_EXPORT

        * Introduction
      ORG
    end

    let(:readme_wo_header) do
      <<~ORG
        * Heading

        Text
      ORG
    end

    let(:readme) { readme_wo_badge_or_marker }

    around do |example|
      Dir.mktmpdir do |dir|
        root = dir
        Dir.chdir(root) do
          File.write(File.join(root, "#{gem_name}.gemspec"), fake_spec)
          File.write(File.join(root, "README.org"), readme)
          workflows_dir = File.join(root, ".github/workflows")
          FileUtils.mkdir_p(workflows_dir)
          File.write(File.join(workflows_dir, "xxx.yml"), "name: XXX")

          example.run
        end
      end
    end

    describe ".ensure!" do
      context "when the badge is missing" do
        let(:readme) { readme_wo_badge_or_marker }

        it "inserts the badge after the title and returns true" do
          result = Badge.ensure!

          expect(result).to be_positive
          written = File.read("README.org")
          expect(written).to include("BEGIN_EXPORT markdown")
          expect(written).to include("actions/workflows/xxx.yml")
          expect(written.index("BEGIN_EXPORT")).to be > written.index("#+TITLE:")
        end
      end

      context "when the badge is already present" do
        let(:readme) { readme_w_badge }

        it "idempotent does not rewrite the file and returns false" do
          pre_run_readme = File.read("README.org")
          Badge.ensure!
          post_run_readme = File.read("README.org")
          Badge.ensure!
          post_post_run_readme = File.read("README.org")

          expect(pre_run_readme).to eq(post_run_readme)
          expect(post_run_readme).to eq(post_post_run_readme)
        end
      end

      context "when the badge marker is present" do
        let(:readme) { readme_wo_badge_w_marker }

        it "inserts badge in place of #badge marker" do
          pre_run_readme = File.read("README.org")
          expect(pre_run_readme).not_to include(/BEGIN_EXPORT markdown/)
          expect(pre_run_readme).to include(/\#badge/)
          Badge.ensure!
          post_run_readme = File.read("README.org")
          expect(post_run_readme).to include(/BEGIN_EXPORT markdown/)
          expect(post_run_readme).not_to include(/\#badge/)
        end
      end

      context "when README has no headers" do
        let(:readme) { readme_wo_header }

        it "falls back to inserting at the top if no title exists" do
          Badge.ensure!
          post_run_readme = File.read("README.org")

          expect(post_run_readme).to start_with("#+BEGIN_EXPORT markdown")
          expect(post_run_readme).to include("* Heading\n\nText")
        end
      end
    end
  end
end
