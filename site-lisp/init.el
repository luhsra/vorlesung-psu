(setq user-init-file (or load-file-name (buffer-file-name)))
(setq load-dir (file-name-directory user-init-file))
(add-to-list 'load-path load-dir)
(add-to-list 'load-path (format "%s/org-plus-contrib-20190701" load-dir))

(message "This is the PSÜ org-mode exporter. Initializing... (%s)" load-dir)
(toggle-debug-on-error)

(require 'org)
(require 'ob-tangle-sra)
(require 'htmlize)

(setq org-html-klipsify-src nil)
(setq org-html-htmlize-font-prefix  "org-")
(setq org-html-htmlize-output-type 'css)


(message "... emacs is started.")
