(require 'ob-tangle)
(require 'ob-latex)
(require 'ox-html)
(require 'ox-tufte)

(require 'org-macro-sra)


(defun org-babel-tangle (&optional arg target-file lang)
  "Write code blocks to source-specific files.
Extract the bodies of all source code blocks from the current
file into their own source-specific files.
With one universal prefix argument, only tangle the block at point.
When two universal prefix arguments, only tangle blocks for the
tangle file of the block at point.
Optional argument TARGET-FILE can be used to specify a default
export file for all source blocks.  Optional argument LANG can be
used to limit the exported source code blocks by language."
  (interactive "P")
  (run-hooks 'org-babel-pre-tangle-hook)
  ;; Possibly Restrict the buffer to the current code block

  ;; CHANGE: copy buffer but restore point
  (let ((point-in-original (point)))
    (org-export-with-buffer-copy
     (goto-char point-in-original) ;; Restore original point
      (when (equal arg '(4))
	(let ((head (org-babel-where-is-src-block-head)))
	  (if head
	      (goto-char head)
	    (user-error "Point is not in a source code block"))))
      (let ((block-counter 0)
	    (org-babel-default-header-args
	     (if target-file
		 (org-babel-merge-params org-babel-default-header-args
					 (list (cons :tangle target-file)))
	       org-babel-default-header-args))
	    (tangle-file
	     (when (equal arg '(16))
	       (or (cdr (assq :tangle (nth 2 (org-babel-get-src-block-info 'light))))
		   (user-error "Point is not in a source code block"))))
	    path-collector)
	(mapc ;; map over all languages
	 (lambda (by-lang)
	   (let* ((lang (car by-lang))
		  (specs (cdr by-lang))
		  (ext (or (cdr (assoc lang org-babel-tangle-lang-exts)) lang))
		  (lang-f (intern
			   (concat
			    (or (and (cdr (assoc lang org-src-lang-modes))
				     (symbol-name
				      (cdr (assoc lang org-src-lang-modes))))
				lang)
			    "-mode")))
		  she-banged)
	     (mapc
	      (lambda (spec)
		(let ((get-spec (lambda (name) (cdr (assoc name (nth 4 spec))))))
		  (let* ((tangle (funcall get-spec :tangle))
			 (she-bang (let ((sheb (funcall get-spec :shebang)))
                                     (when (> (length sheb) 0) sheb)))
			 (tangle-mode (funcall get-spec :tangle-mode))
			 (base-name (cond
				     ((string= "yes" tangle)
				      (file-name-sans-extension
				       (nth 1 spec)))
				     ((string= "no" tangle) nil)
				     ((> (length tangle) 0) tangle)))
			 (file-name (when base-name
				      ;; decide if we want to add ext to base-name
				      (if (and ext (string= "yes" tangle))
					  (concat base-name "." ext) base-name))))
		    (when file-name
		      ;; Possibly create the parent directories for file.
		      (let ((m (funcall get-spec :mkdirp))
			    (fnd (file-name-directory file-name)))
			(and m fnd (not (string= m "no"))
			     (make-directory fnd 'parents)))
		      ;; delete any old versions of file
		      (and (file-exists-p file-name)
			   (not (member file-name (mapcar #'car path-collector)))
			   (delete-file file-name))
		      ;; drop source-block to file
		      (with-temp-buffer
			(when (fboundp lang-f) (ignore-errors (funcall lang-f)))
			(when (and she-bang (not (member file-name she-banged)))
			  (insert (concat she-bang "\n"))
			  (setq she-banged (cons file-name she-banged)))
			(org-babel-spec-to-string spec)
			;; We avoid append-to-file as it does not work with tramp.
			(let ((content (buffer-string)))
			  (with-temp-buffer
			    (when (file-exists-p file-name)
			      (insert-file-contents file-name))
			    (goto-char (point-max))
			    ;; Handle :padlines unless first line in file
			    (unless (or (string= "no" (cdr (assq :padline (nth 4 spec))))
					(= (point) (point-min)))
			      (insert "\n"))
			    (insert content)
			    (write-region nil nil file-name))))
		      ;; if files contain she-bangs, then make the executable
		      (when she-bang
			(unless tangle-mode (setq tangle-mode #o755)))
		      ;; update counter
		      (setq block-counter (+ 1 block-counter))
		      (unless (assoc file-name path-collector)
			(push (cons file-name tangle-mode) path-collector))))))
	      specs)))
	 (if (equal arg '(4))
	     (org-babel-tangle-single-block 1 t)
	   (org-babel-tangle-collect-blocks lang tangle-file)))
	(message "Tangled %d code block%s from %s" block-counter
		 (if (= block-counter 1) "" "s")
		 (file-name-nondirectory
		  (buffer-file-name
		   (or (buffer-base-buffer) (current-buffer)))))
	;; run `org-babel-post-tangle-hook' in all tangled files
	(when org-babel-post-tangle-hook
	  (mapc
	   (lambda (file)
	     (org-babel-with-temp-filebuffer file
	       (run-hooks 'org-babel-post-tangle-hook)))
	   (mapcar #'car path-collector)))
	;; set permissions on tangled files
	(mapc (lambda (pair)
		(when (cdr pair) (set-file-modes (car pair) (cdr pair))))
	      path-collector)
	(mapcar #'car path-collector)))))


(defun org-babel-tangle-collect-blocks (&optional language tangle-file)
  "Collect source blocks in the current Org file.
Return an association list of source-code block specifications of
the form used by `org-babel-spec-to-string' grouped by language.
Optional argument LANGUAGE can be used to limit the collected
source code blocks by language.  Optional argument TANGLE-FILE
can be used to limit the collected code blocks by target file."
  (let ((counter 0) last-heading-pos blocks)
    (org-babel-map-src-blocks nil
      (let ((current-heading-pos
	     (org-with-wide-buffer
	      (org-with-limited-levels (outline-previous-heading)))))
	(if (eq last-heading-pos current-heading-pos) (cl-incf counter)
	  (setq counter 1)
	  (setq last-heading-pos current-heading-pos)))
      (unless (org-in-commented-heading-p)
	(let* ((info (org-babel-get-src-block-info 'light))
	       (src-lang (nth 0 info))
	       (src-tfile (cdr (assq :tangle (nth 2 info)))))
	  (unless (or (string= src-tfile "no")
		      (and tangle-file (not (equal tangle-file src-tfile)))
		      (and language (not (string= language src-lang))))
	    ;; Add the spec for this block to blocks under its
	    ;; language.
	    (let ((by-lang (assoc src-lang blocks))
		  (block (org-babel-tangle-single-block counter)))
	      (if by-lang (setcdr by-lang (cons block (cdr by-lang)))
		(push (cons src-lang (list block)) blocks)))))))
    ;; Ensure blocks are in the correct order.
    (mapcar (lambda (b) (cons (car b) (nreverse (cdr b))))
	    (nreverse blocks))))


(defvar org-babel-tangle-current-entry nil) ;; dynamic variable to communicate with macro mechanism
(setq org-babel-tangle--get-property
      "(eval (org-with-wide-buffer (org-entry-get org-babel-tangle-current-entry $1 'selective)))")

(defun org-babel-tangle-single-block (block-counter &optional only-this-block)
  "Collect the tangled source for current block.
Return the list of block attributes needed by
`org-babel-tangle-collect-blocks'.  When ONLY-THIS-BLOCK is
non-nil, return the full association list to be used by
`org-babel-tangle' directly."
  (let* ((info (org-babel-get-src-block-info))
	 (start-line
	  (save-restriction (widen)
			    (+ 1 (line-number-at-pos (point)))))
	 (file (buffer-file-name (buffer-base-buffer)))
	 (src-lang (nth 0 info))
	 (params (nth 2 info))
	 (extra (nth 3 info))
	 (cref-fmt (or (and (string-match "-l \"\\(.+\\)\"" extra)
			    (match-string 1 extra))
		       org-coderef-label-format))
	 (link (let ((l (org-no-properties (org-store-link nil))))
                 (and (string-match org-bracket-link-regexp l)
                      (match-string 1 l))))
         (org-babel-tangle-current-entry
          (condition-case nil
              (org-entry-beginning-position)
            (error nil)))
         (macros (progn
                   (org-macro-initialize-templates)
                   (append
                    (list `(property . ,org-babel-tangle--get-property))
                    org-macro-templates
                    org-export-global-macros)))
	 (source-name
	  (or (nth 4 info)
	      (format "%s:%d"
		      (or (ignore-errors (nth 4 (org-heading-components)))
			  "No heading")
		      block-counter)))
	 (expand-cmd (intern (concat "org-babel-expand-body:" src-lang)))
	 (assignments-cmd
	  (intern (concat "org-babel-variable-assignments:" src-lang)))
         (prologue (cdr (assq :tangle-prologue params)))
         (epilogue (cdr (assq :tangle-epilogue params)))
	 (body
	  ;; Run the tangle-body-hook.
          (let* ((datum (org-element-context))
                 (beg (org-element-property :begin datum))
                 (end (org-element-property :end datum))
                 (beg-line (1+ (count-lines 1 beg)))
                 (end-line (1+ (count-lines 1 end)))
                 (body (if (org-babel-noweb-p params :tangle)
                           (progn
                             (if prologue
                                 (setf (nth 1 info)
                                       (format "<<%s>>\n%s" prologue (nth 1 info))))
                             (if epilogue
                                 (setf (nth 1 info)
                                       (format "%s\n<<%s>>" (nth 1 info) epilogue)))
                             (setq macros
                                   `(("range" . ,(format "%s-%s" beg-line end-line))
                                     ("subtitle" . ,(org-macro--find-keyword-value "SUBTITLE" t))
                                     ,@macros))
                             (org-babel-expand-noweb-references info))
			 (nth 1 info)))
                 (body (cond ((assq :no-expand params) body)
		             ((fboundp expand-cmd) (funcall
		             expand-cmd body params))
		             (t
		              (org-babel-expand-body:generic
		               body params (and (fboundp assignments-cmd)
					        (funcall assignments-cmd params))))))

                 (old-block (buffer-substring beg end))
                 result)
            (save-restriction
              (narrow-to-region beg end)
              (delete-region (point-min) (point-max))
              (insert body)
              (when (string-match "-r" extra)
	        (goto-char (point-min))
	        (while (re-search-forward
		        (replace-regexp-in-string "%s" ".+" cref-fmt) nil t)
		  (replace-match "")))
	      (run-hooks 'org-babel-tangle-body-hook)
              (if (string= "yes" (cdr (assq :tangle-macros params)))
                  (org-macro-replace-all macros))
	      (setq result (buffer-string))
              (delete-region (point-min) (point-max))
              (insert old-block)
              result)
            ))
	 (comment
	  (when (or (string= "both" (cdr (assq :comments params)))
		    (string= "org" (cdr (assq :comments params))))
	    ;; From the previous heading or code-block end
	    (funcall
	     org-babel-process-comment-text
	     (buffer-substring
	      (max (condition-case nil
		       (save-excursion
			 (org-back-to-heading t) ; Sets match data
			 (match-end 0))
		     (error (point-min)))
		   (save-excursion
		     (if (re-search-backward
			  org-babel-src-block-regexp nil t)
			 (match-end 0)
		       (point-min))))
	      (point)))))
	 (result
	  (list start-line
		(if org-babel-tangle-use-relative-file-links
		    (file-relative-name file)
		  file)
		(if (and org-babel-tangle-use-relative-file-links
			 (string-match org-link-types-re link)
			 (string= (match-string 0 link) "file"))
		    (concat "file:"
			    (file-relative-name (match-string 1 link)
						(file-name-directory
						 (cdr (assq :tangle params)))))
		  link)
		source-name
		params
		(if org-src-preserve-indentation
		    (org-trim body t)
		  (org-trim (org-remove-indentation body)))
		comment)))
    (if only-this-block
	(list (cons src-lang (list result)))
      result)))

(defun org-tufte-src-block (src-block contents info)
  (org-html-src-block src-block contents info))

(defun org-export-to-html-file (src dst)
  (interactive)
  (let (buffer (find-buffer-visiting src))
    (message "HTML %s: %s" src buffer)
    (with-current-buffer
        (find-file-noselect src)
      (org-export-to-file 'tufte-html dst)
      )
    (when (not buffer)
      (message "kill buffer %s: %s" src buffer)
      (kill-buffer (find-buffer-visiting src)))))

(defun org-babel-tangle-file (file &optional target-file lang)
  "Extract the bodies of source code blocks in FILE.
Source code blocks are extracted with `org-babel-tangle'.
Optional argument TARGET-FILE can be used to specify a default
export file for all source blocks.  Optional argument LANG can be
used to limit the exported source code blocks by language.
Return a list whose CAR is the tangled file name."
  (interactive "fFile to tangle: \nP")
  (let ((visited-p (find-buffer-visiting (expand-file-name file)))
	to-be-removed)
    (message "kill2: %s %s" file visited-p)
    (org-macro--counter-initialize t)
    (prog1
	(save-window-excursion
	  (find-file file)
	  (setq to-be-removed (current-buffer))
	  (mapcar #'expand-file-name (org-babel-tangle nil target-file lang)))
      (unless visited-p
	(kill-buffer to-be-removed)))))


(provide 'ob-tangle-sra)
