(setq user-init-file (or load-file-name (buffer-file-name)))
(setq load-dir (file-name-directory user-init-file))
(setq org-sra-src-dir (file-name-directory (directory-file-name load-dir)))

(add-to-list 'load-path load-dir)

(require 'package)
(setq package-archives
      '(("melpa" . "http://melpa.milkbox.net/packages/")
        ("marmalade" . "https://marmalade-repo.org/packages/")
        ("gnu" . "https://elpa.gnu.org/packages/")
        ("org" . "http://orgmode.org/elpa/")))
(setq package-user-dir load-dir)
(package-initialize)

(message "This is the PSÜ org-mode exporter. Initializing... (%s)" load-dir)
(toggle-debug-on-error)

(require 'org)
(require 'ob-tangle-sra)
(require 'ox-html)
(require 'htmlize)

(setq org-html-klipsify-src nil)
(setq org-html-htmlize-font-prefix  "org-")
(setq org-html-htmlize-output-type 'css)
(setq org-html-postamble
      (with-temp-buffer
        (insert-file-contents
         (format "%s/COPYING.footer.html" org-sra-src-dir))
        (buffer-string)))

(message "... emacs is started.")
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
