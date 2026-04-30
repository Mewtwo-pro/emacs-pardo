(defun smart-jump-with-folds ()
  (interactive)
  (let* ((labels (append (number-sequence ?a ?z)
                         (number-sequence ?A ?Z)))
         (label-map (make-hash-table))
         (overlays '())
         (idx 0)
         (start (window-start))
         (end (window-end)))

    ;; Detectar overlay de fold (hideshow)
    (defun my-fold-overlay-at (pos)
      (when (bound-and-true-p hs-minor-mode)
        (cl-find-if
         (lambda (ov)
            (overlay-get ov 'hs))
         (overlays-at pos))))

    ;; 1. Dibujar etiquetas
    (save-excursion
      (goto-char start)
      (while (and (< (point) end)
                  (< idx (length labels)))

        ;; Solo etiquetar líneas visibles
        (unless (invisible-p (point))
          (let* ((char (nth idx labels))
                 (pos (line-beginning-position))
                 (ov (make-overlay pos pos)))

            ;; guardar relación char → posición
            (puthash char pos label-map)

            ;; mostrar overlay
            (overlay-put ov 'before-string
                         (propertize (format " %c " char)
                                     'face 'highlight))
            (push ov overlays)

            (setq idx (1+ idx))))

        ;; Saltar folds correctamente
        (let ((ov (my-fold-overlay-at (point))))
          (if ov
              (goto-char (overlay-end ov)) ;; salto directo al final del fold
            (forward-line 1)))))

    (redisplay)

    ;; permitir SPACE para aceptar
    (define-key minibuffer-local-map (kbd "SPC")
      (lambda ()
        (interactive)
        (exit-minibuffer)))

    ;; 2. input
    (let ((input (read-string "Ir a (e) o rango (ex): ")))

      ;; limpiar overlays
      (mapc #'delete-overlay overlays)

      ;; 3. lógica
      (cond
       ;; salto simple
       ((= (length input) 1)
        (setq my-toggle-var 1)
	(messages-mode my-toggle-var)
        (let ((target (gethash (string-to-char input) label-map)))
          (when target
            (goto-char target))))

       ;; selección rango
       ((>= (length input) 2)
        (setq my-toggle-var 2)
	(messages-mode my-toggle-var)
        (let* ((start-pos (gethash (aref input 0) label-map))
               (end-pos   (gethash (aref input 1) label-map)))
          (when (and start-pos end-pos)
            (goto-char start-pos)
            (set-mark (point))
            (goto-char end-pos)
            (forward-line 1))))))))
	    
(defun jump-to-indent-step ()
  "Muestra etiquetas de la 'a' a la 'z' cada 4 espacios en blanco al inicio de la línea."
  (interactive)
  (let* ((start (line-beginning-position))
         (text-start (save-excursion 
                       (back-to-indentation) 
                       (point)))
         (indent-area (buffer-substring-no-properties start text-start))
         (len (length indent-area))
         (positions '())
         (overlays '())
         (char-code ?a))

    ;; 1. Calcular posiciones cada 4 espacios
    (let ((i 0))
      (while (and (< i len) (<= char-code ?z))
        (push (cons (+ start i) (char-to-string char-code)) positions)
        (setq i (+ i 4))
        (setq char-code (1+ char-code))))

    (if (null positions)
        (message "No hay suficientes espacios a la izquierda.")
      
      ;; 2. Crear Overlays visuales
      (dolist (pos positions)
        (let ((ov (make-overlay (car pos) (1+ (car pos)))))
          (overlay-put ov 'display (cdr pos))
          (overlay-put ov 'face '(:background "#ff0000" :foreground "white" :bold t))
          (push ov overlays)))

      ;; 3. Leer la tecla de salto
      (message "Presiona la letra para saltar...")
      (let ((input (read-char)))
        (let ((target (assoc-default (char-to-string input) 
                                     (mapcar (lambda (x) (cons (cdr x) (car x))) positions) 
                                     'string=)))
          (if target
              (goto-char target)
            (message "Salto cancelado."))))

      ;; 4. Limpiar visuales
      (dolist (ov overlays)
        (delete-overlay ov)))))
	
(defun jump-to-indent-select ()
  "Muestra etiquetas de la 'a' a la 'z' cada 4 espacios en blanco al inicio de la línea."
  (interactive)
  (let* ((start (line-beginning-position))
         (text-start (save-excursion 
                       (back-to-indentation) 
                       (point)))
         (indent-area (buffer-substring-no-properties start text-start))
         (len (length indent-area))
         (positions '())
         (overlays '())
         (char-code ?a))

    ;; 1. Calcular posiciones cada 4 espacios
    (let ((i 0))
      (while (and (< i len) (<= char-code ?z))
        (push (cons (+ start i) (char-to-string char-code)) positions)
        (setq i (+ i 4))
        (setq char-code (1+ char-code))))

    (if (null positions)
        (message "No hay suficientes espacios a la izquierda.")
      
      ;; 2. Crear Overlays visuales
      (dolist (pos positions)
        (let ((ov (make-overlay (car pos) (1+ (car pos)))))
          (overlay-put ov 'display (cdr pos))
          (overlay-put ov 'face '(:background "#ff0000" :foreground "white" :bold t))
          (push ov overlays)))

      ;; 3. Leer la tecla de salto
      (message "Presiona la letra para saltar...")
      (let ((input (read-char)))
        (let ((target (assoc-default (char-to-string input) 
                                     (mapcar (lambda (x) (cons (cdr x) (car x))) positions) 
                                     'string=)))
          (if target
              (salto-indent target)
            (message "Salto cancelado."))))

      ;; 4. Limpiar visuales
      (dolist (ov overlays)
        (delete-overlay ov)))))

(defun salto-indent (target)
  (goto-char target)
  (push-mark nil t t)
  (back-to-indentation)
    (when (use-region-p)
	    (delete-region (region-beginning) (region-end))
	    (deactivate-mark))
    (setq my-toggle-var 1)
    (messages-mode my-toggle-var))
