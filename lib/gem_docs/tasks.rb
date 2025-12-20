# frozen_string_literal: true

module GemDocs
  extend Rake::DSL

  ORG   = "README.org"
  MD    = "README.md"
  STAMP = ".tangle-stamp"

  def self.install
    extend Rake::DSL

    # README.org → README.md when README.org is newer
    file MD => ORG do
      print "Exporting \"#{ORG}\" → "
      GemDocs::Emacs.export_readme
    end

    # Evaluate code blocks only when README.org changes
    file STAMP => ORG do
      print "Executing code blocks in #{ORG} ... "
      GemDocs::Emacs.tangle
      FileUtils.touch(STAMP)
    end

    namespace :docs do
      desc "Evaluate code blocks in README.org"
      task :tangle => STAMP

      desc "Export README.org → README.md"
      task :export => [:badge, MD]

      desc "Extract overview from README.org and embed in lib/<gem>.rb for ri/yard"
      task :overview => ORG do
        print "Embedding overview extracted from #{GemDocs::ORG} into main gem file... "
        GemDocs::Overview.write_overview_to_lib
        puts "OK"
      end

      desc "Generate YARD HTML documentation"
      task :yard => [:overview] do
        puts "Generating YARD documentation..."
        GemDocs::Yard.generate
      end

      desc "Ensure GitHub Actions badge exists in README.org"
      task :badge do
        print "Ensuring badges are in README.org ... "

        if GemDocs::Badges.ensure!
          puts "added"
        else
          puts "already present"
        end
      end

      desc "Run all documentation tasks (examples, readme, overview, yard, ri)"
      task :all => [:tangle, :export, :overview, :yard]
    end
  end
end
