# frozen_string_literal: true

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

    let(:readme) do
      <<~ORG
        #+PROPERTY: header-args:ruby :results value :colnames no :hlines yes :exports both :dir "./"
        #+PROPERTY: header-args:ruby :wrap example :session fake_gem_session
        #+PROPERTY: header-args:ruby+ :prologue "require_relative 'lib/fat_fin'" :eval yes
        #+PROPERTY: header-args:sh :exports code :eval no
        #+PROPERTY: header-args:bash :exports code :eval no
        #+TITLE: FakeGem

        * Introduction
        Some text here.

        #+begin_src ruby
          result = []
          result << ['Head1', 'Head2']
          result << nil
          1.upto(20) do |k|
            result << [k, k**3]
          end
          result
        #+end_src
      ORG
    end

    let(:results) do
      <<~RESULT
        #+RESULTS:
        #+begin_example
        | Head1 | Head2 |
        |-------+-------|
        |     1 |     1 |
        |     2 |     8 |
        |     3 |    27 |
        |     4 |    64 |
        |     5 |   125 |
        |     6 |   216 |
        |     7 |   343 |
        |     8 |   512 |
        |     9 |   729 |
        |    10 |  1000 |
        |    11 |  1331 |
        |    12 |  1728 |
        |    13 |  2197 |
        |    14 |  2744 |
        |    15 |  3375 |
        |    16 |  4096 |
        |    17 |  4913 |
        |    18 |  5832 |
        |    19 |  6859 |
        |    20 |  8000 |
        #+end_example
      RESULT
    end

    around do |example|
      Dir.mktmpdir do |dir|
        root = dir
        Dir.chdir(root) do
          File.write(File.join(root, "fake_gem.gemspec"), fake_spec)
          File.write(File.join(root, "README.org"), readme)

          example.run
        end
      end
    end

    describe ".export" do
      context "when the org file is saved" do
        it "produces the README.md" do
          expect(File).not_to exist("README.md")
          Emacs.export
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
          Emacs.export
          post_stat = File.stat("README.org")
          expect(post_stat.mtime >= mod_stat.mtime).to be_truthy
          expect(File).to exist("README.md")
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
    end
  end
end
