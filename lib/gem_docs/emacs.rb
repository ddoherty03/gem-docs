# frozen_string_literal: true

module GemDocs
  module Emacs
    def self.tangle
      expr = <<~ELISP
        (save-window-excursion
          (if (get-buffer "#{session_name}")
            (kill-buffer "#{session_name}"))
          (with-current-buffer (find-file-noselect "#{README_ORG}")
            (save-buffer)
            (require 'ob-ruby)
            (org-babel-execute-buffer)
            (save-buffer)
            "OK"))
      ELISP

      unless system("emacsclient", "--quiet", "--eval", expr)
        abort "Babel execution failed"
      end
    end

    def self.export
      expr = <<~ELISP
        (save-window-excursion
          (with-current-buffer (find-file-noselect "#{README_ORG}")
            (save-buffer)
            (require 'ox-gfm)
            (org-gfm-export-to-markdown)))
      ELISP

      system("emacsclient", "--quiet", "--eval", expr)
    end

    def self.session_name
      "*#{Repo.from_gemspec.name}_session*"
    end
  end
end
