(require 'org-element)
(require 'org-macro)
(require 's)

(defun org-macro--counter-initialize (&optional new-file)
  "Initialize `org-macro--counter-table'."
  (if new-file
      (setq org-macro--counter-table (make-hash-table :test #'equal))))

(defun org-global-props (&optional property buffer)
  "Get the plists of global org properties of current buffer."
  (unless property (setq property "PROPERTY"))
  (with-current-buffer (or buffer (current-buffer))
    (org-element-map (org-element-parse-buffer) 'keyword (lambda (el) (when (string-match property (org-element-property :key el)) el)))))

(defun org-global-prop-value (key)
  "Get global org property KEY of current buffer."
  (org-element-property :value (car (org-global-props key))))

(defun org-macro-headlines (file)
    (let ((parsetree  (org-element-parse-buffer 'headline))
	  (res "") (sep ""))
      (org-element-map parsetree 'headline
	(lambda (headline)
          (let ((id (org-element-property :CUSTOM_ID headline))
		(tags (org-element-property :tags headline))
		(title (org-element-property :title headline)))
            (unless (or (not id) (member 'noexport tags))
              (setq res (format "%s%s<a href=\"%s#%s\">%s</a>"
				res sep (s-replace ".org" ".html" file)
				id title))
              (setq sep " - ")))))
      res))

(defun org-macro-topic (file img)
 (with-file-from-disk file
  (let* ((url (s-replace ".org" ".html" file))
         (date (org-global-prop-value "date"))
         (date-html (if date (format "<span class=\"structure\">%s</span> " date) ""))
         )
    (concat
     "#+begin_export html\n"
     (format "<h2>%s<a href=\"%s\">%s</a></h2>"
             date-html
             url (org-global-prop-value "subtitle"))
     (format "<div class=\"row\"><div class=\"col-md-4\"><img class=\"img-index\" src=\"%s\"></div>" img)
     "<div class=\"col-md-8\">\n"
     "<p> Abschnitte: "
     (message "%s" (org-macro-headlines file))
     "</p></div></div>\n"
     "#+end_export\n"
     ))))

;;; SRA-ADDON: Add INCLUDE to the search regexp
(defun org-macro--collect-macros (&optional files templates)
  "Collect macro definitions in current buffer and setup files.
Return an alist containing all macro templates found.

FILES is a list of setup files names read so far, used to avoid
circular dependencies.  TEMPLATES is the alist collected so far.
The two arguments are used in recursive calls."
  (let ((case-fold-search t))
    (org-with-point-at 1
      (while (re-search-forward "^[ \t]*#\\+\\(MACRO\\|SETUPFILE\\|INCLUDE\\):" nil t)
	(let ((element (org-element-at-point)))
	  (when (eq (org-element-type element) 'keyword)
	    (let ((val (org-element-property :value element)))
	      (if (equal "MACRO" (org-element-property :key element))
		  ;; Install macro in TEMPLATES.
		  (when (string-match "^\\(\\S-+\\)[ \t]*" val)
		    (let ((name (match-string 1 val))
			  (value (substring val (match-end 0))))
		      (setq templates
			    (org-macro--set-template name value templates))))
		;; Enter setup file.
		(let* ((uri (org-strip-quotes val))
		       (uri-is-url (org-file-url-p uri))
		       (uri (if uri-is-url
				uri
			      (expand-file-name uri))))
		  ;; Avoid circular dependencies.
		  (unless (member uri files)
		    (with-temp-buffer
		      (unless uri-is-url
			(setq default-directory (file-name-directory uri)))
		      (org-mode)
		      (insert (org-file-contents uri 'noerror))
		      (setq templates
			    (org-macro--collect-macros
			     (cons uri files) templates)))))))))))
    (let ((macros `(("author" . ,(org-macro--find-keyword-value "AUTHOR"))
		    ("email" . ,(org-macro--find-keyword-value "EMAIL"))
		    ("title" . ,(org-macro--find-keyword-value "TITLE" t))
		    ("date" . ,(org-macro--find-date)))))
      (pcase-dolist (`(,name . ,value) macros)
	(setq templates (org-macro--set-template name value templates))))
    templates))

(defun org-macro-sra-see (custom_id title)
  (let* ((prefix (car (s-split "-" custom_id)))
         (files (directory-files org-sra-src-dir nil (format "%s-.*\\.org" prefix)))
	 (org-file (car files)))
    (format "[fn::Siehe [[file:%s::#%s][%s]].]" org-file custom_id title)))


(provide 'org-macro-sra)
