# frozen_string_literal: true

require 'date'

module GemDocs
  RSpec.describe Emacs do
    let(:fake_spec) do
      <<~RUBY
        Gem::Specification.new do |spec|
          spec.name        = "fake_gem"
          spec.version     = "0.9.10"
          spec.summary     = "Fakes as a first-class data type"
          spec.authors     = ["Bruce Wayne"]

          spec.metadata = {
            "source_code_uri" => "https://github.com/bwayne/fake_gem",
          }
        end
      RUBY
    end

    let(:lib_square) do
      <<~RUBY
        module FakeGem
          def self.table
            result = []
            result << ['N', 'N Squared']
            result << nil
            1.upto(20) do |k|
              result << [k, k**2]
            end
            result
          end
        end
      RUBY
    end

    let(:lib_cube) do
      <<~RUBY
        module FakeGem
          def self.table
            result = []
            result << ['N', 'N Cubed']
            result << nil
            1.upto(20) do |k|
              result << [k, k**3]
            end
            result
          end
        end
      RUBY
    end

    let(:lib) { lib_square }

    let(:readme) do
      <<~ORG
        #{GemDocs::Header.org_headers}
        #+TITLE: FakeGem

        * Introduction
        Some text here.

        #+begin_src ruby
          FakeGem.table
        #+end_src
      ORG
    end

    let(:changelog) do
      <<~ORG
        * [2025-12-27 Sat] Version 0.3.0
        - Added export of CHANGELOG.org to CHANGELOG.md
        - Added this CHANGELOG so I have an example to use in my specs.  Oh, and for
          users also.
        * [2025-12-23 Tue] Version 0.2.0
        - Make tangle of README.org unconditional, even is it is not newer than
          README.md.  The code examples depend on more than just the text of
          README.org, they especially depend on changes to the gem's lib code, so
          running unconditionally is usually what is wanted.
        - Before docs:tangle, kill the session buffer for ruby code blocks so each run
          is independent of prior runs and the current version of the gem lib gets
          loaded.
        * [2025-12-23 Fri] Version 0.1.2
        - Initial release
      ORG
    end

    let(:results_square) do
      <<~RESULT
        #+RESULTS:
        #+begin_example
        |  N | N Squared |
        |----+-----------|
        |  1 |         1 |
        |  2 |         4 |
        |  3 |         9 |
        |  4 |        16 |
        |  5 |        25 |
        |  6 |        36 |
        |  7 |        49 |
        |  8 |        64 |
        |  9 |        81 |
        | 10 |       100 |
        | 11 |       121 |
        | 12 |       144 |
        | 13 |       169 |
        | 14 |       196 |
        | 15 |       225 |
        | 16 |       256 |
        | 17 |       289 |
        | 18 |       324 |
        | 19 |       361 |
        | 20 |       400 |
        #+end_example
      RESULT
    end

    let(:results_cube) do
      <<~RESULT
        #+RESULTS:
        #+begin_example
        |  N | N Cubed |
        |----+---------|
        |  1 |       1 |
        |  2 |       8 |
        |  3 |      27 |
        |  4 |      64 |
        |  5 |     125 |
        |  6 |     216 |
        |  7 |     343 |
        |  8 |     512 |
        |  9 |     729 |
        | 10 |    1000 |
        | 11 |    1331 |
        | 12 |    1728 |
        | 13 |    2197 |
        | 14 |    2744 |
        | 15 |    3375 |
        | 16 |    4096 |
        | 17 |    4913 |
        | 18 |    5832 |
        | 19 |    6859 |
        | 20 |    8000 |
        #+end_example
      RESULT
    end

    let(:results) { results_square }

    let(:gemfile) do
      <<~GEM
        source "https://rubygems.org"

        gemspec
        gem "irb"
      GEM
    end

    around do |example|
      Dir.mktmpdir do |dir|
        root = dir
        Dir.chdir(root) do
          File.write(File.join(root, "fake_gem.gemspec"), fake_spec)
          File.write(File.join(root, "Gemfile"), gemfile)
          File.write(File.join(root, "README.org"), readme)
          File.write(File.join(root, "CHANGELOG.org"), changelog)
          lib_dir = File.join(root, "lib/")
          FileUtils.mkdir_p(lib_dir)
          File.write(File.join(lib_dir, "fake_gem.rb"), lib)

          example.run
        end
      end
    end

    describe ".export_readme" do
      context "when the org file is saved" do
        it "produces the README.md" do
          expect(File).not_to exist("README.md")
          Emacs.export_readme
          expect(File).to exist("README.md")
        end
      end

      context "when the org file is not saved" do
        it "saves and produces the README.md" do
          # Add to the end of the README.org file
          pre_stat = File.stat("README.org")
          File.write("README.org", "* Additional Head")
          mod_stat = File.stat("README.org")
          expect(mod_stat.mtime > pre_stat.mtime).to be_truthy
          expect(File).not_to exist("README.md")
          Emacs.export_readme
          post_stat = File.stat("README.org")
          expect(post_stat.mtime >= mod_stat.mtime).to be_truthy
          expect(File).to exist("README.md")
        end
      end
    end

    describe ".export_changelog" do
      context "when the org file is saved" do
        it "produces the CHANGELOG.md" do
          expect(File).not_to exist("CHANGELOG.md")
          Emacs.export_changelog
          expect(File).to exist("CHANGELOG.md")
        end
      end

      context "when the org file is not saved" do
        it "saves and produces the CHANGELOG.md" do
          # Add to the end of the CHANGELOG.org file
          pre_stat = File.stat("CHANGELOG.org")
          File.write("CHANGELOG.org", "* [#{Date.today.iso8601}] Version X.X.y")
          mod_stat = File.stat("CHANGELOG.org")
          expect(mod_stat.mtime > pre_stat.mtime).to be_truthy
          expect(File).not_to exist("CHANGELOG.md")
          Emacs.export_changelog
          post_stat = File.stat("CHANGELOG.org")
          expect(post_stat.mtime >= mod_stat.mtime).to be_truthy
          expect(File).to exist("CHANGELOG.md")
        end
      end
    end

    describe '.tangle' do
      context 'when the org file is saved' do
        it 'runs the code blocks' do
          pre_contents = File.read("README.org")
          expect(pre_contents).not_to match(/^\s*#+RESULTS/)
          Emacs.tangle
          post_contents = File.read("README.org")
          expect(post_contents).to match(/\#\+RESULTS/)
          expect(post_contents).to include(results)
        end
      end

      context 'when the library file is changed' do
        it 'runs the code blocks in a new session' do
          pre_contents = File.read("README.org")
          expect(pre_contents).not_to match(/^\s*#+RESULTS/)
          Emacs.tangle
          post_contents = File.read("README.org")
          expect(post_contents).to match(/\#\+RESULTS/)
          expect(post_contents).to include(results)
          # Now change the lib to produce cubed table
          File.write(File.join('./lib', "fake_gem.rb"), lib_cube)
          Emacs.tangle
          post_contents = File.read("README.org")
          expect(post_contents).to match(/\#\+RESULTS/)
          expect(post_contents).to include(results_cube)
        end
      end

      # rubocop:disable RSpec/MultipleMemoizedHelpers
      context 'when the org file is not saved' do
        let(:new_block) do
          <<~BLK
            #+begin_src ruby
              result = []
              result << ['Add1', 'Add2']
              result << nil
              1.upto(20) do |k|
                result << [k, k^2]
              end
              result
            #+end_src
          BLK
        end

        it 'saves then runs the code blocks' do
          pre_stat = File.stat("README.org")
          f = File.new("README.org", 'a+')
          f.write(new_block)
          f.flush
          mod_stat = File.stat("README.org")
          expect(mod_stat.mtime > pre_stat.mtime).to be_truthy
          Emacs.tangle
          post_stat = File.stat("README.org")
          expect(post_stat.mtime >= mod_stat.mtime).to be_truthy
          post_contents = File.read("README.org")
          lines = post_contents.lines
          result_lines = lines.select { |l| l.include?('#+RESULTS') }
          expect(result_lines.size).to eq(2)
        end
      end
      # rubocop:enable RSpec/MultipleMemoizedHelpers
    end
  end
end
