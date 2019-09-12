(require 'org-element)
(require 'org-macro)
(require 's)

(defun org-macro--counter-initialize (&optional new-file)
  "Initialize `org-macro--counter-table'."
  (if new-file
      (setq org-macro--counter-table (make-hash-table :test #'equal))))

(defun org-macro-headlines (file)
  (with-file-from-disk file
    (let ((data  (org-element-parse-buffer 'headline))
	  (res "") (sep ""))
       (dolist (headline (cddr data))
         (let ((id (org-element-property :CUSTOM_ID headline))
               (tags (org-element-property :tags headline))
               (title (org-element-property :title headline)))
           (unless (or (not id) (member 'noexport tags))
             (setq res (format "%s%s[[%s#%s][%s]]"
                               res sep (s-replace ".org" ".html" file)
			       id title))
             (setq sep " - "))))
       res)))

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
	 (org-file (car (directory-files "." nil (format "%s-.*\\.org" prefix)))))
    (format "[fn::Siehe [[file:%s::#%s][%s]].]" org-file custom_id title)))


(provide 'org-macro-sra)
