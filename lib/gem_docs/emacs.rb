module GemDocs
  extend self

  # Save README.org buffer if modified inside a running emacsclient
  def ensure_saved
    expr = <<~ELISP
      (progn
        (when (get-buffer "#{ORG}")
          (with-current-buffer "#{ORG}"
            (when (buffer-modified-p)
              (save-buffer))))
        "")
    ELISP

    unless system("emacsclient", "--quiet", "--eval", expr)
      abort("Failed to ensure README.org was saved")
    end
  end

  # Run all org-babel Ruby blocks
  def evaluate_examples
    expr = <<~ELISP
      (progn
        (find-file "#{ORG}")
        (require 'ob-ruby)
        (org-babel-execute-buffer)
        (save-buffer)
        "OK")
    ELISP

    if system("emacsclient", "--quiet", "--eval", expr)
      FileUtils.touch(STAMP)
    else
      puts "ERROR"
      abort "Babel execution failed"
    end
  end

  # Export README.org → README.md via ox-gfm
  def export_readme
    expr = <<~ELISP
      (progn
        (find-file "#{ORG}")
        (require 'ox-gfm)
        (org-gfm-export-to-markdown))
    ELISP

    system("emacsclient", "--eval", expr)
  end
end
