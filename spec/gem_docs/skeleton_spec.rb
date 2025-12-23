# frozen_string_literal: true

module GemDocs
  RSpec.describe Skeleton do
    let(:fake_spec) do
      <<~RUBY
        Gem::Specification.new do |spec|
          spec.name        = "fake_gem"
          spec.version     = "0.9.10"
          spec.summary     = "Fakes as a first-class data type"
          spec.authors     = ["Bruce Wayne"]

          spec.metadata = {
            "source_code_uri" => "https://github.com/bwayne/fake_spec",
          }
        end
      RUBY
    end

    let(:readme) do
      <<~README
        #+TITLE: FakeGem Guide

        * Introduction
        You're gonna love it!
      README
    end

    let(:add_readme) { false }

    around do |example|
      Dir.mktmpdir do |dir|
        root = dir
        Dir.chdir(root) do
          File.write(File.join(root, "README.org"), readme) if add_readme
          File.write(File.join(root, "fake_gem.gemspec"), fake_spec)
          # lib_dir = File.join(root, "lib/")
          # FileUtils.mkdir_p(lib_dir)
          # File.write(File.join(lib_dir, "fake_gem.rb"), main_lib)
          File.write("Gemfile", '#Empty')
          example.run
        end
      end
    end

    describe ".write_overview?" do
      context "when there is no README.org yet" do
        it "adds README.org the repo" do
          expect(Skeleton).not_to be_present
          expect(Skeleton.make_readme?).to be true
          expect(Skeleton).to be_present
        end
      end

      context "when the overview is already present" do
        let(:add_readme) { true }

        it "does not add an additional overview" do
          expect(Skeleton).to be_present
          expect(Skeleton.make_readme?).to be false
          expect(Skeleton).to be_present
        end
      end
    end
  end
end
