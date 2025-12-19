# frozen_string_literal: true

module GemDocs
  RSpec.describe Badges do
    let(:readme_path) { Badges::README }

    let(:metadata) do
      {
        "source_code_uri" => "https://github.com/ded/fat_table",
        "changelog_uri" => "https://github.com/ded/fat_table/blob/master/CHANGELOG.md",
      }
    end

    let(:repo_double) do
      instance_double("GemDocs::Repo")
    end

    let(:initial_readme) do
      <<~ORG
        #+TITLE: FatTable

        * Introduction
        Some text here.
      ORG
    end

    let(:readme_with_badge) do
      <<~ORG
        #+TITLE: FatTable

        #+BEGIN_EXPORT markdown
        [![CI](https://github.com/ded/fat_table/actions/workflows/ci.yml/badge.svg)](
        https://github.com/ded/fat_table/actions/workflows/ci.yml
        )
        #+END_EXPORT

        * Introduction
      ORG
    end

    before do
      allow(Repo).to receive(:from_gemspec).and_return(repo_double)
      allow(repo_double).to receive(:user).and_return('ded')
      allow(repo_double).to receive(:name).and_return('fat_table')
      stub_const("GemDocs::Badges::README", readme_path)
    end

    describe ".ensure_github_actions!" do
      context "when the badge is missing" do
        it "inserts the badge after the title and returns true" do
          allow(File).to receive(:read).and_call_original
          allow(File).to receive(:read).with(readme_path).and_return(initial_readme)
          written = nil
          allow(File).to receive(:write) { |_, content| written = content }

          result = Badges.ensure_github_actions!

          expect(result).to be true
          expect(written).to include("BEGIN_EXPORT markdown")
          expect(written).to include("actions/workflows/ci.yml")
          expect(written.index("BEGIN_EXPORT")).to be > written.index("#+TITLE:")
        end
      end

      context "when the badge is already present" do
        it "does not rewrite the file and returns false" do
          allow(File).to receive(:read).with(readme_path).and_return(readme_with_badge)
          expect(File).not_to have_received(:write)

          result = Badges.ensure_github_actions!

          expect(result).to be false
        end
      end
    end

    describe ".ensure_all!" do
      it "delegates to ensure_github_actions!" do
        expect(Badges).to have_receives(:ensure_github_actions!).and_return(true)
        Badges.ensure_all!
      end
    end

    describe ".insert_after_title" do
      it "falls back to inserting at the top if no title exists" do
        content = "* Heading\nText"
        block = "BADGE"

        result = Badges.insert_after_title(content, block)

        expect(result).to start_with("* Heading\n\nBADGE")
      end
    end
  end
end
