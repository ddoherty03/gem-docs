# frozen_string_literal: true

module GemDocs
  extend Rake::DSL

  ORG   = "README.org"
  MD    = "README.md"
  STAMP = ".examples-stamp"

  def self.install
    extend Rake::DSL

    task :save do
      GemDocs.ensure_saved
    end

    # README.org → README.md when README.org is newer
    file MD => ORG do
      print "Exporting \"#{ORG}\" → "
      GemDocs.export_readme
    end

    # Evaluate code blocks only when README.org changes
    file STAMP => [:save, ORG] do
      print "Executing code blocks in #{ORG} ... "
      GemDocs.evaluate_examples
      FileUtils.touch(STAMP)
    end

    namespace :docs do
      desc "Evaluate Ruby examples in README.org"
      task :examples => STAMP

      desc "Export README.org → README.md"
      task :readme => MD

      desc "Extract overview from README.org and embed in lib/<gem>.rb for ri/yard"
      task :overview do
        print "Embedding overview extracted from #{GemDocs::ORG} into main gem file... "
        GemDocs::Overview.write_overview_to_lib
        puts "OK"
      end

      desc "Generate YARD HTML documentation"
      task :yard => [:overview] do
        puts "Generating YARD documentation..."
        GemDocs::Yard.generate
      end

      desc "Run all documentation tasks (examples, readme, overview, yard, ri)"
      task :all => [:examples, :readme, :overview, :yard]
    end
  end
end
