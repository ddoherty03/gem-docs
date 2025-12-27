# frozen_string_literal: true

module GemDocs
  def self.install
    extend Rake::DSL

    file README_MD => README_ORG do
      print "Exporting \"#{README_ORG}\" → "
      GemDocs::Emacs.export_readme
    end

    file CHANGELOG_MD => CHANGELOG_ORG do
      print "Exporting \"#{CHANGELOG_ORG}\" → "
      GemDocs::Emacs.export_changelog
    end

    namespace :docs do
      desc "Evaluate code blocks in README.org"
      task :tangle => ["skeleton:readme"] do
        print "Executing code blocks in #{README_ORG} ... "
        GemDocs::Emacs.tangle
      end

      desc "Export README.org → README.md"
      task :export => [:badge, README_MD, CHANGELOG_MD]

      desc "Extract overview from README.org and embed in lib/<gem>.rb for ri/yard"
      task :overview => [:skeleton, README_ORG] do
        print "Embedding overview extracted from #{GemDocs::README_ORG} into main gem file ... "
        if GemDocs::Overview.write_overview?
          puts "added"
        else
          puts "already present"
        end
      end

      namespace :skeleton do
        desc "Create skeleton README.org if one does not exist"
        task :readme do
          if GemDocs::Skeleton.make_readme?
            puts "README.org added"
          else
            puts "README.org already present"
          end
        end

        desc "Create skeleton CHANGELOG.org if one does not exist"
        task :changelog do
          if GemDocs::Skeleton.make_changelog?
            puts "CHANGELOG.org added"
          else
            puts "CHANGELOG.org already present"
          end
        end
      end

      desc "Insert #+PROPERTY headers at top of README.org for code blocks"
      task :header => "skeleton:readme" do
        print "Inserting headers ... "
        if GemDocs::Header.write_header?
          puts "added"
        else
          puts "already present"
        end
      end

      desc "Generate YARD HTML documentation"
      task :yard => [:overview] do
        puts "Generating YARD documentation ... "
        GemDocs::Yard.generate
      end

      desc "Ensure GitHub Actions badge exists in README.org"
      task :badge => "skeleton:readme" do
        print "Ensuring badges are in README.org ... "
        if GemDocs::Badge.ensure!
          puts "added"
        else
          puts "already present"
        end
      end

      desc "Run all documentation tasks (examples, readme, overview, yard, ri)"
      task :all => ["skeleton:readme", "skeleton:changelog", :header, :tangle, :export, :overview, :yard]
    end
  end
end
