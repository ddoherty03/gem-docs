# frozen_string_literal: true

module GemDocs
  module Yard
    # Generate HTML documentation via YARD
    def self.generate
      write_yardopts
      Dir.chdir(GemDocs.project_root) do
        unless system("yard", "doc", "--no-private")
          abort "Failed to generate YARD documentation"
        end
      end
    end

    class << self
      private

      # Path to the .yardopts file in the project root
      def yardopts_path
        File.expand_path(".yardopts", GemDocs.project_root)
      end

      # Contents of .yardopts
      def yardopts_contents
        <<~YOPTS
          --markup markdown
          --output-dir doc
          --readme README.md
          lib/**/*.rb
        YOPTS
      end

      # Write .yardopts only if needed
      def write_yardopts
        if !File.exist?(yardopts_path) || File.read(yardopts_path) != yardopts_contents
          File.write(yardopts_path, yardopts_contents)
        end
      end
    end
  end
end
