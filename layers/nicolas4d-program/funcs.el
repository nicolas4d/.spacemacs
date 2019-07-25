(defun nicolas4d/tags-project-root()
  (let ((directory default-directory))
    (locate-dominating-file directory ".TAGS_conf")
    )
  )

(defun nicolas4d/setup-tags-project-environment ()
  (interactive)
  (if (nicolas4d/tags-project-root)
      (setq tags-table-list (list (nicolas4d/tags-project-root)))
    )
  )

(defun nicolas4d/create-tags-if-needed (SRC-DIR &optional FORCE)
  "return the full path of tags file"
  (let ((dir (file-name-as-directory (file-truename SRC-DIR)))
        file)
    (setq file (concat dir "TAGS"))
    (when (spacemacs/system-is-mswindows)
      (setq dir (substring dir 0 -1)))
    (when (or FORCE (not (file-exists-p file)))
      (message "Creating TAGS in %s ..." dir)
      (shell-command
       (format "ctags -f %s -e -R %s" file dir)))
    file))

(defun nicolas4d/update-tags ()
  (interactive)
  "check the tags in tags-table-list and re-create it"
  (if (nicolas4d/tags-project-root) ;; prevent tags-project to create tags not in tags-project file
      (dolist (tag tags-table-list)
        (nicolas4d/create-tags-if-needed (file-name-directory tag) t)))
    )

(advice-add 'save-buffer :after #'nicolas4d/update-tags)
