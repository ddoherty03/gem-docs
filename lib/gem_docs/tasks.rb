# frozen_string_literal: true

require "rake"
require "fileutils"

# Rake tasks for generating documentation for gems.
module GemDocs
  ORG   = "README.org"
  MD    = "README.md"
  STAMP = ".gem-docs-stamp"

  # Automatically installs tasks when required from Rakefile
  def self.install
    Rake.application.in_namespace(:docs) do
      # Ruby code block execution
      file STAMP => ORG do
        GemDocs.ensure_saved
        GemDocs.evaluate_examples
      end

      # Export README.org → README.md
      file MD => ORG do
        GemDocs.ensure_saved
        GemDocs.export_to_markdown
      end

      desc "Execute all Ruby code blocks in README.org via org-babel"
      task :examples => STAMP

      desc "Export README.org → README.md (GFM)"
      task :readme => MD
    end
  end

  #------------------------------#
  #  Helper methods              #
  #------------------------------#

  # Ensure buffer is saved before evaluation or export
  def self.ensure_saved
    expr = %[
      (progn
        (setq revert-without-query '(".*")
              save-silently t)
        (find-file "#{File.expand_path(ORG)}")
        (when (buffer-modified-p)
          (save-buffer))
        "OK")
    ]

    system("emacsclient", "--eval", expr) or
      abort "gem-docs: Could not save README.org"
  end

  # Run org-babel across the entire README
  def self.evaluate_examples
    expr = %[
      (progn
        (find-file "#{File.expand_path(ORG)}")
        (require 'ob-ruby)
        (org-babel-execute-buffer)
        (save-buffer)
        "OK")
    ]

    print "Evaluating Ruby code blocks in #{ORG} ... "
    if system("emacsclient", "--eval", expr)
      FileUtils.touch(STAMP)
      puts "OK"
    else
      puts "ERROR"
      abort "gem-docs: Babel evaluation failed"
    end
  end

  # Export README.org → README.md (GitHub Flavored Markdown)
  def self.export_to_markdown
    expr = %[
      (progn
        (find-file "#{File.expand_path(ORG)}")
        (require 'ox-gfm)
        (org-gfm-export-to-markdown))
    ]

    print "Exporting #{ORG} → #{MD} ... "
    if system("emacsclient", "--eval", expr)
      puts "OK"
    else
      puts "ERROR"
      abort "gem-docs: Markdown export failed"
    end
  end
end
