(defun git-rama-commit-view ()
  "Selecciona branch -> commit -> abre el archivo actual en ese estado con resaltado."
  (interactive)
  (let* ((file (buffer-file-name))
         (current-mode major-mode) ;; <--- 1. Guardamos el modo actual (ej. js-mode)
         (git-root (vc-git-root file)))
    (if (not git-root)
        (message "No estás en un repo Git")
      (let* ((default-directory git-root)
             (branch (completing-read "Branch: " 
                        (process-lines "git" "branch" "--all" "--format=%(refname:short)")))
             (commit-line (completing-read "Commit: "
                             (process-lines "git" "log" branch "--pretty=format:%h %s")))
             (hash (car (split-string commit-line " ")))
             (rel-file (file-relative-name file git-root))
             (buf-name (format "*Revision %s: %s*" hash (file-name-nondirectory file))))
        
        (let ((content (shell-command-to-string (format "git show %s:%s" hash rel-file))))
          (if (or (not content) (string-empty-p content))
              (message "El archivo no existe en ese commit o está vacío")
            (let ((new-buf (get-buffer-create buf-name)))
              (with-current-buffer new-buf
                (setq buffer-read-only nil)
                (erase-buffer)
                (insert content)
                ;; 2. Aplicamos el modo guardado explícitamente
                (funcall current-mode) 
                (setq buffer-read-only t))
              (display-buffer-in-side-window new-buf '((side . bottom) (window-height . 0.5))))))))))
(defun git-rama-add-commit ()
  (interactive)
  (let* ((file (buffer-file-name))
         (git-root (vc-git-root file)))
    (if (not git-root)
        (message "No estás en un repo Git")
      (let* ((default-directory git-root)
             (rel-file (file-relative-name file git-root))
             ;; 1. Seleccionar rama
             (branch (completing-read "Checkout a rama: " 
                        (process-lines "git" "branch" "--all" "--format=%(refname:short)")))
             ;; 2. Cambiar de rama
             (_ (shell-command (format "git checkout %s" branch)))
             ;; 3. Pedir mensaje de commit
             (msg (read-string (format "Commit mensaje para %s: " rel-file))))
        
        (if (string-empty-p msg)
            (message "Commit cancelado")
          ;; 4. Add y Commit
          (shell-command (format "git add %s" (shell-quote-argument rel-file)))
          (message (shell-command-to-string (format "git commit -m %s" (shell-quote-argument msg)))))))))

