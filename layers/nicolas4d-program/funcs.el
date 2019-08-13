;;tags-company
(defvar tags-company/conf ".TAGS_CONF"
  "tags-company configuration default file name")

(defvar tags-company/start-create-tags-msg "Creating TAGS in %s ..."
  "message when start create tags or update tags")

(defvar tags-company/create-tags-command-and-option "ctags -f %s -e -R %s"
  "create tags command and option string")

(defvar tags-company/tags-file-name "TAGS"
  "default tags file name.")

(defvar tags-company/set-environment-msg "set tags-company environment succeed")
(defvar tags-company/unset-environment-succeed-msg "unset tags-company environment succeed")
(defvar tags-company/unset-environment-not-found-msg "not found tags-company environment")

(defun tags-company/find-environment()
  "locate tags company root directory.
find directory that contain tags-company-conf."
  (let ((directory default-directory))
    (locate-dominating-file directory tags-company/conf)))

(defun tags-company/set-up-company ()
  "make use of custom tags file for company-mode"
  (if (tags-company/find-environment)
      (setq tags-table-list (list (tags-company/find-environment)))
    (setq tags-table-list nil)))

(defun tags-company/create-tags (SRC-DIR &optional FORCE)
  "Cteate tags.
command use create-tags-command-and-option."
  (let ((dir (file-name-as-directory (file-truename SRC-DIR)))
        file)
    (setq file (concat dir tags-company/tags-file-name))
    (when (spacemacs/system-is-mswindows)
      (setq dir (substring dir 0 -1)))
    (when (or
           FORCE
           (not (file-exists-p file)))
      (message tags-company/start-create-tags-msg dir)
      (shell-command
       (format tags-company/create-tags-command-and-option file dir)))
    file))

(defun tags-company/update-tags ()
  "check the tags in tags-table-list and re-create it."
  (interactive)
  (tags-company/set-up-company)
  (dolist (tags-file tags-table-list)
    (make-thread
     (tags-company/create-tags (file-name-directory tags-file) t))))

(defun tags-company/set-environment()
  "create tags-company/conf configuration file."
  (interactive)
  (dired-create-empty-file tags-company/conf)
  (message tags-company/set-environment-msg))

(defun tags-company/unset-environment()
  "remove tags-company/conf configuration file"
  (interactive)
  (if (file-exists-p tags-company/conf)
      (progn
        (dired-delete-file tags-company/conf)
        (message tags-company/unset-environment-succeed-msg))
    (message tags-company/unset-environment-not-found-msg)))

(advice-add 'save-buffer :after #'tags-company/update-tags)

;; the others
