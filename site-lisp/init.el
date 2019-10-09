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


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values '((ospl-mode . 1))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(message "... emacs is started.")
