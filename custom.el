(log "Custom Initialization")

(setq org-html-postamble
      (with-temp-buffer
        (insert-file-contents
         (format "%s/COPYING.footer.html" org-lecture-src-dir))
        (buffer-string)))

