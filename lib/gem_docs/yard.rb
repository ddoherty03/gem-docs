# frozen_string_literal: true

module GemDocs
  module Yard
    extend self

    # Path to the .yardopts file in the project root
    def yardopts_path
      File.expand_path(".yardopts", project_root)
    end

    # Auto-detect project root (handles being run from subdirs)
    def project_root
      @project_root ||= begin
        here = Dir.pwd
        here = File.dirname(here) until File.exist?(File.join(here, "Gemfile")) || here == "/"
        here
      end
    end

    # Contents of .yardopts
    def yardopts_contents
      <<~YOPTS
        --markup markdown
        --output-dir doc
        README.md
        lib/**/*.rb
      YOPTS
    end

    # Write .yardopts only if needed
    def write_yardopts
      if !File.exist?(yardopts_path) || File.read(yardopts_path) != yardopts_contents
        File.write(yardopts_path, yardopts_contents)
      end
    end

    # Generate HTML documentation via YARD
    def generate
      write_yardopts
      Dir.chdir(project_root) do
        unless system("yard", "doc", "--no-private")
          abort "Failed to generate YARD documentation"
        end
      end
    end
  end
end
