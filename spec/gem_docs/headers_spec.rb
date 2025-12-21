# frozen_string_literal: true

module GemDocs
  RSpec.describe Header do
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

    let(:readme_wo_ruby_head) do
      <<~ORG
        #! emacs

        # mode: org

        #+PROPERTY: header-args:R :results value :colnames no :hlines yes :exports both :dir "./"
        #+PROPERTY: header-args:R+ :wrap example :session fake_gem_session
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

    let(:readme_w_no_head) do
      <<~ORG
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

    let(:readme_w_ruby_head) do
      <<~ORG
        #+PROPERTY: header-args:ruby :results value :colnames no :hlines yes :exports both :dir "./"
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

    around do |example|
      Dir.mktmpdir do |dir|
        root = dir
        Dir.chdir(root) do
          File.write(File.join(root, "fake_spec.gemspec"), fake_spec)
          File.write(File.join(root, "README.org"), readme)

          example.run
        end
      end
    end

    describe ".write_header?" do
      context "when there is no header" do
        let(:readme) { readme_w_no_head }

        it "adds the ruby headers at the top of the file" do
          expect(Header).not_to be_present
          expect(Header.write_header?).to be true
          expect(Header).to be_present
        end
      end

      context "when there is a header but no ruby header" do
        let(:readme) { readme_wo_ruby_head }

        it "adds the ruby headers at the top of the file" do
          expect(Header).not_to be_present
          expect(Header.write_header?).to be true
          expect(Header).to be_present
        end
      end

      context "when there is already a ruby header" do
        let(:readme) { readme_w_ruby_head }

        it "does not change the README file" do
          pre_org = File.read(ORG)
          expect(Header).to be_present
          expect(Header.write_header?).to be false
          post_org = File.read(ORG)
          expect(pre_org).to eq(post_org)
          expect(Header).to be_present
        end
      end
    end
  end
end
