(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(leuven-dark))
 '(package-selected-packages '(ivy ubuntu-theme yaru-theme counsel company cape))
 '(tool-bar-mode nil)
 '(tool-bar-position 'left))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 '(default ((t (:family "JetBrains Mono" :foundry "JB" :slant normal :weight bold :height 158 :width normal)))))
(add-hook 'dired-mode-hook 'dired-hide-details-mode)
(setq-default indent-tabs-mode nil)	
(setq-default tab-width 4)

;; Desactivar archivos de respaldo (archivo~)
(setq make-backup-files nil)
;; Desactivar auto-guardado (#archivo#)
(setq auto-save-default nil)
;; Desactivar la creación de archivos de bloqueo (lockfiles .#archivo)
(setq create-lockfiles nil)
 
;; regex-patron    
(defvar mis-nombres-guardados nil
  "Lista de nombres extraídos recientemente para su reutilización.")

;; 2. Atajo 1: Extraer y GUARDAR los nombres (sin cambios)
(defun guardar-nombres-region (start end)
  "Guarda la primera palabra de cada línea en `mis-nombres-guardados`."
  (interactive "r")
  (if (use-region-p)
      (let* ((texto (buffer-substring-no-properties start end))
             (lineas (split-string texto "\n" t))
             (nombres (delq nil
                            (mapcar (lambda (linea)
                                      (car (split-string linea "[ \t\r\n]+" t)))
                                    lineas))))
        (setq mis-nombres-guardados nombres)
        (message "Guardados" ))
    (message "Selecciona un bloque de texto primero.")))

    
(defun aplicar-plantilla-con-nombres (start end)
  (interactive "r")
  (cond
   ((null mis-nombres-guardados)
    (message "Primero debes guardar nombres con 'C-c n'."))
   ((not (use-region-p))
    (message "Selecciona la línea plantilla primero."))
   (t
    (let* ((plantilla (buffer-substring-no-properties start end))
           (bloque-generado
            (mapconcat
             (lambda (nombre)
               (let* (;; Solo cambia el primer carácter a mayúscula
                      (nombre-m (if (and nombre (> (length nombre) 0))
                                    (concat (upcase (substring nombre 0 1))
                                            (substring nombre 1))
                                  nombre))
                      (linea plantilla))
                 ;; 1. Reemplazar patronM (respetando mayúsculas internas)
                 (setq linea (replace-regexp-in-string (regexp-quote "patronM")
                                                       nombre-m linea t t))
                 ;; 2. Reemplazar patron (original)
                 (setq linea (replace-regexp-in-string (regexp-quote "patron")
                                                       nombre linea t t))
                 ;; 3. Reemplazar {} (comodín por defecto)
                 (setq linea (replace-regexp-in-string (regexp-quote "{}")
                                                       nombre linea t t))
                 linea))
             mis-nombres-guardados
             "\n")))
      (delete-region start end)
      (insert bloque-generado)
      (message "Plantilla para %d nombres." (length mis-nombres-guardados))))))
    
(defun mi-seleccionar-contenido-delimitador ()
  (interactive)
  (let* ((char-actual (char-after))
         (aperturas '(?\" ?\' ?\( ?\[ ?\{)))
    (if (and char-actual (memq char-actual aperturas))
        (let (inicio fin)
          (save-excursion
            (setq inicio (1+ (point))) ; después del delimitador
            (forward-sexp 1)
            (setq fin (1- (point))))   ; antes del delimitador de cierre

          (goto-char inicio)
          (set-mark fin)
          (activate-mark)

          (setq var-toggle 2)
          (setq select-mode 1))
      (message "El cursor no está sobre un delimitador de apertura."))))
      
(defun nueva-terminal ()
  (interactive)
  (let ((buf (generate-new-buffer "*terminal*")))
    (with-current-buffer buf
      (term-mode)
      (term-exec buf "terminal" "/bin/bash" nil nil))
    (switch-to-buffer buf)))
    

(defun mi/saltar-siguiente-misma-indentacion ()
  "Mueve el cursor a la siguiente línea que tenga la misma indentación que la actual."
  (interactive)
  (let ((indent-actual (current-indentation)))
    (forward-line 1)
    ;; Avanza mientras no sea el final del buffer y la indentación sea distinta
    (while (and (not (eobp))
                (or (looking-at-p "^[ \t]*$") ; ignora líneas vacías
                    (/= (current-indentation) indent-actual)))
      (forward-line 1))
    ;; Coloca el cursor en el nivel de indentación
    (back-to-indentation)))
    
(defun mi/saltar-anterior-misma-indentacion ()
  (interactive)
  (let ((indent-actual (current-indentation)))
    (forward-line -1)
    (while (and (not (bobp))
                (or (looking-at-p "^[ \t]*$") ; ignora líneas vacías
                    (/= (current-indentation) indent-actual)))
      (forward-line -1))
    (back-to-indentation)))

(defun mi-atajo-rapido ()
  (interactive)
  (message "Presiona una letra : ")
 "Presiona una letra : "
  (let ((char (read-key))) ; Lee una tecla al instante sin pedir Enter
    (cond
     ((eq char ?i)
        (mi/saltar-siguiente-misma-indentacion)
      (setq var-toggle 1))
     ((eq char ?g)
        (mi-atajo-git))
     ((eq char ?t)
        (mi/saltar-anterior-misma-indentacion)
      (setq var-toggle 1))
     ((eq char ?u)
        (nueva-terminal))
     ((eq char ?m)
      (goto-char (point-max))
      (setq var-toggle 1))
     ((eq char ? )                      
       (open-comands))
     ((eq char ?s)
      (delete-region (point) (line-beginning-position))
      (setq var-toggle 1))
     ((eq char ?d)
      (delete-region (point) (line-end-position))
      (setq var-toggle 1))
     ((eq char ?p)
       (mi-seleccionar-contenido-delimitador))
     ((eq char ?n)
      (goto-char (point-min))
      (setq var-toggle 1))
     ((eq char ?b)
      (mark-whole-buffer)
      (setq var-toggle 2)
      (setq select-mode 1))
     (t
      (message "Tecla '%c' no reconocida." char)))))
      
      
(defun mi-atajo-chars ()
  (interactive)
  (message "Presiona una letra : ")
 "Presiona una letra : "
  (let ((char (read-key))) 
    (cond
     ((eq char ?m)
      (insert "@")     
      (setq var-toggle 0))
     ((eq char ?v)
      (insert "ñ")     
      (setq var-toggle 0))
     ((eq char ?b)
      (insert "``")     
      (backward-char 1)
      (setq var-toggle 0))
     ((eq char ?n)
      (insert "~")     
      (setq var-toggle 0))
     ((eq char ?u)
		(seleccionar-word-simbol) 
          (kill-region (region-beginning) (region-end))
		  (deactivate-mark)
        (Buscarfilex)                  
        (setq var-toggle 4))
     ((eq char ?p)
		(seleccionar-word-simbol) 
          (kill-region (region-beginning) (region-end))
		  (deactivate-mark)
        (Buscarsolofilex)                  
        (setq var-toggle 4))

     (t
      (message "Tecla '%c' no reconocida." char)))))
      
;; ripgrep



(defun xripgrep()
  (interactive)
  (setq var-toggle 0)
  (let* ((ruta-especifica "/home/manuel/Documents/javaProyect/springBoot/demo")
         ;; 1. Pedir el input al usuario
         (termino-busqueda (read-string "Buscar (ripgrep) en carpeta: ")))
    
    ;; Validar que el usuario no haya dejado el input vacío
    (if (string-empty-p (string-trim termino-busqueda))
        (message "Búsqueda cancelada: término vacío.")
      
      ;; 2. Ejecutar counsel-rg usando la ruta y el input inicial
      (let ((default-directory (file-name-as-directory ruta-especifica)))
        (counsel-rg termino-busqueda default-directory)))))

;; terminal mode

(defvar-local busqueda-term-buffer nil)

(defun FinalizarInput ()
  (interactive)
  (let ((comando (string-trim (buffer-string)))
        (term-buffer busqueda-term-buffer))
    ;(kill-buffer) ; Cierra el buffer temporal

    (when (buffer-live-p term-buffer)
      (with-current-buffer term-buffer 
        (term-send-raw-string (concat comando "\n"))))))

(defun Buscarfilex ()
  (interactive)
  (let ((comando "~/Documents/bashScript/buscarfilecarpeta.sh")
        (term-buffer busqueda-term-buffer))
    ;(kill-buffer) ; Cierra el buffer temporal

    (when (buffer-live-p term-buffer)
      (with-current-buffer term-buffer 
        (term-send-raw-string (concat comando "\n"))))))

(defun Buscarsolofilex ()
  (interactive)
  (let ((comando "~/Documents/bashScript/buscarsolofile.sh")
        (term-buffer busqueda-term-buffer))
    ;(kill-buffer) ; Cierra el buffer temporal

    (when (buffer-live-p term-buffer)
      (with-current-buffer term-buffer 
        (term-send-raw-string (concat comando "\n"))))))

;; Modo mayor para el buffer temporal
(define-derived-mode busqueda-term-mode text-mode "BusquedaTerm"
  "Modo para ingresar comandos a una terminal.")

;; Atajo del modo
(define-key busqueda-term-mode-map (kbd "RET") #'FinalizarInput)

(defun BuscarMode ()
  (interactive)
  (let ((term-buffer (current-buffer)))
    ;; Abre una ventana pequeña abajo
    (split-window-vertically -4)
    (other-window 1)

    ;; Crea un NUEVO buffer temporal
    (switch-to-buffer (generate-new-buffer "*BusquedaTerm*"))
    (erase-buffer)

    ;; Activa el modo especial
    (busqueda-term-mode)

    ;; Este buffer recuerda a qué terminal pertenece
    (setq busqueda-term-buffer term-buffer)

    (message "Escribe tu comando y presiona Enter.")))
    
(defun tab-simbol ()
  (interactive)
      (cond  
	((= my-toggle-var 0)		
	  (setq my-toggle-var 4)
	) 
	((= my-toggle-var 4)
	  (forward-char)
	  (setq my-toggle-var 0)
	)
     )
)
(defun set-term-command ()
  (interactive)
  (tab-bar-new-tab)
  (term "/bin/bash") 
  (term-send-string (get-buffer-process (current-buffer)) "ls\n"))
  
(with-eval-after-load 'term
  (define-key term-raw-map (kbd "-") 'BuscarMode)
  (define-key term-raw-map (kbd ";") 'term-line-mode))
    
(add-hook 'term-mode-hook
  (lambda ()
    ;; Para cuando estás en line-mode
    (define-key term-mode-map (kbd "`") 'term-char-mode)
    (define-key term-mode-map (kbd "1") #'completion-at-point)))
;;plegado - fold	
(add-hook 'prog-mode-hook #'outline-minor-mode)
(defvar fold-mode 1)
(defun select-fold-mode ()
  "Elegir el modo de plegado."
  (interactive)
  (let ((choice (completing-read
                 "Modo de plegado: "
                 '("Outline" "Hideshow")
                 nil t)))
    ;; Desactivar ambos primero
    (when (bound-and-true-p outline-minor-mode)
      (outline-minor-mode -1))
    (when (bound-and-true-p hs-minor-mode)
      (hs-minor-mode -1))

    ;; Activar el elegido
    (pcase choice
      ("Outline"
       (outline-minor-mode 1)
       (setq fold-mode 1)
       (message "Outline Plegado Mode"))
      ("Hideshow"
       (hs-minor-mode 1)
       (setq fold-mode 2)
       (message "Hideshow Mode activado")))))

;; Quitar barra de herramihentas
(tool-bar-mode -1)
;; Quitar menoú
(menu-bar-mode -1)
;; Quitar scroll
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)

;; Variable global para guardar la línea
(defvar my-saved-line nil		;
  "Línea guardada del cursor en el buffer actual.")
;; Función para guardar la línea actual
(defun my-save-current-line ()
  "Guarda la línea actual del cursor en `my-saved-line`."
  (interactive)
  (setq my-saved-line (line-number-at-pos))
  (message "Línea %d guardada" my-saved-line))
(defvar my-saved-point nil )
(defun my-save-current-position ()
  (interactive)
  (setq my-saved-point (point-marker))
  (message "Posición guardada"))

(defun my-jump-and-select-to-saved-position ()
  (interactive)
  (if (and (boundp 'my-saved-point) my-saved-point)
      (let ((current-pos (point)))
        ;; 1. Coloca la marca en la posición actual
        (set-mark current-pos)
        ;; 2. Mueve el cursor a la posición guardada
        (goto-char my-saved-point)
        ;; 3. Activa la región visualmente
        (activate-mark)
        (message "Regresado y seleccionado"))
    (message "No hay ninguna posición guardada.")))
  
(defun my-jump-to-saved-line ()
  "Mueve el cursor a la línea guardada en `my-saved-line`."
  (interactive)
  (if my-saved-line
      (progn
        (goto-char (point-min))
        (forward-line (1- my-saved-line))
        (message "Saltado a la línea %d" my-saved-line))
    (message "No hay ninguna línea guardada aún.")))
(defun my-select-from-saved-line ()
  "Selecciona desde la línea guardada hasta la posición actual."
  (interactive)
  (if my-saved-line
      (let ((start (save-excursion
                     (goto-line my-saved-line)
                     (point)))
            (end (point)))
        (goto-char start)
        (set-mark-command nil)
        (goto-char end))
    (message "No hay línea guardada. Usa `my-save-current-line` primero.")))
		    
(defun my-fold-level (level)
  (interactive "nNivel indent: ")
  (hide-sublevels level))  
(setq visible-bell t)
(setq ring-bell-function 'ignore)

(defun set-select-buscar ()
    (interactive)
    (when (use-region-p)    
    (setq buscar-palabra 
        (buffer-substring-no-properties
            (region-beginning)
            (region-end)
        )))
    (deactivate-mark)
    (setq buscar-mode 1)
    (setq var-toggle 1) 
    (message "Buscando : %s" buscar-palabra)
)

(defun on-buscar ()
    (interactive)
    (deactivate-mark)
    (setq buscar-mode 1)
    (setq var-toggle 1) 
    (message "Buscando : %s" buscar-palabra)
)

(defun seleccionar-simbolo-actual ()
	"Selecciona el simbolo completo donde esta el cursor."
	(interactive)
	(let ((inicio (bounds-of-thing-at-point 'symbol)))
		(when inicio
			(goto-char (car inicio))
			(set-mark (cdr inicio))
			(activate-mark))))
                
(defun seleccionar-word-simbol ()
  "Selecciona el símbolo o ruta completa donde está el cursor, incluyendo la tilde."
  (interactive)
  (let ((inicio (car (bounds-of-thing-at-point 'symbol)))
        (fin (cdr (bounds-of-thing-at-point 'symbol))))
    (when (and inicio fin)
      ;; Retroceder de forma manual si el carácter anterior es una tilde
      (when (and (> inicio (point-min))
                 (eq (char-after (1- inicio)) ?~))
        (setq inicio (1- inicio)))
      
      (goto-char inicio)
      (set-mark fin)
      (activate-mark))))
;; dired mode

(defun my/dired-copy-full-path ()
  "Copia la ruta completa del archivo o directorio sobre el cursor en Dired al portapapeles."
  (interactive)
  (let ((filename (dired-get-filename nil t)))
    (if filename
        (progn
          (kill-new filename)
          (message "Ruta copiada al portapapeles: %s" filename))
      (message "No hay ningún archivo o directorio en esta línea."))))

;; Mapea la tecla "1" únicamente cuando estés dentro de Dired
(defun my/open-in-external-file-manager ()
  "Abre el directorio actual de Dired en el explorador de archivos del sistema."
  (interactive)
  (let ((path (dired-current-directory)))
    (cond
     ((eq system-type 'windows-nt)
      ;; Windows File Explorer (convierte las barras / a \)
      (call-process "explorer.exe" nil 0 nil (replace-regexp-in-string "/" "\\" path t t)))
     ((eq system-type 'darwin)
      ;; macOS Finder
      (call-process "open" nil 0 nil path))
     ((eq system-type 'gnu/linux)
      ;; Linux (utiliza xdg-open para abrir el gestor por defecto)
      (call-process "xdg-open" nil 0 nil path)))))
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "x") #'my/open-in-external-file-manager))
  
(defun mi-dired-crear-nodo (nombre)
  (interactive "sNew file (carpeta /): ")
  (let ((ruta-completa (expand-file-name nombre dired-directory)))
    (if (string-suffix-p "/" nombre)
        ;; Si termina en /, creamos un directorio
        (progn
          (make-directory ruta-completa t)
          (message "Carpeta creada: %s" nombre))
      ;; Si no, creamos un archivo vacío
      (progn
        (write-region "" nil ruta-completa nil nil nil 'excl)
        (message "Archivo creado: %s" nombre)(setq var-toggle 1)))
    ;; Refrescar el buffer de Dired para ver los cambios inmediatamente
    (revert-buffer)))
(defun new-file-dired ()
    (interactive)
    (setq var-toggle 0)
    (call-interactively 'mi-dired-crear-nodo)
)
(defun renombrar-dired ()
    (interactive)
    (setq var-toggle 0)
    (call-interactively 'dired-do-rename)
)
(defun buscar-dired ()
  (interactive)
     (palabra-buscar)
)
(defun prev-buscar-dired()
    (interactive)
        (search-backward buscar-palabra))

(require 'json)

(defun save-task-play ()
  "Busca play.json en el directorio actual y actualiza emacsTask.json."
  (interactive)

  (let* ((dir (dired-current-directory))
         (play-file (expand-file-name "play.json" dir))
         (task-file "/home/manuel/emacsTask.json"))

    (if (not (file-exists-p play-file))
        (message "No existe play.json")
      ;; Leer play.json
      (let (play-data task-data)

        (with-temp-buffer
          (insert-file-contents play-file)
          (setq play-data
                (json-parse-buffer
                 :object-type 'hash-table)))

        ;; Leer emacsTask.json
        (with-temp-buffer
          (insert-file-contents task-file)
          (setq task-data
                (json-parse-buffer
                 :object-type 'hash-table)))

        ;; Copiar valores
        (puthash "play"
                 (gethash "play" play-data)
                 task-data)

        (puthash "path"
                 (gethash "path" play-data)
                 task-data)

        (puthash "cmd"
                 (gethash "cmd" play-data)
                 task-data)

        ;; Guardar
(with-temp-file task-file
  (insert (json-serialize task-data)))
        (message "emacsTask.json actualizado.")))))
    

(defun ejecutar-term-task ()
  "Lee emacsTask.json, abre vterm o term en la ruta especificada y ejecuta el comando."
  (interactive)
  (let ((archivo "/home/manuel/emacsTask.json"))
    (if (file-exists-p archivo)
        (let* ((json-object-type 'hash-table)
               (json-key-type 'string)
               (json-false 'nil)
               ;; Lee y parsea el archivo JSON
               (datos (json-read-file archivo))
               (ruta (gethash "path" datos))
               (comando (gethash "cmd" datos)))
          
          (if (and ruta comando)
              (progn
                ;; Cambia el directorio por defecto de Emacs a la ruta del JSON
                (let ((default-directory (file-name-as-directory ruta)))
                  ;; Abre la terminal (puedes usar 'ansi-term' o 'vterm' si lo prefieres)
                  (term "/bin/bash")
                  ;; Espera un breve momento a que la terminal cargue y envía el comando
                  (sleep-for 0.2)
                  (process-send-string (get-buffer-process (current-buffer)) 
                                       (concat comando "\n"))))
            (message "Error: No se encontró 'path' o 'cmd' en el archivo JSON.")))
      (message "Error: El archivo %s no existe." archivo))))
(defun ejecutar-term-play ()
  "Lee emacsTask.json, abre vterm o term en la ruta especificada y ejecuta el comando."
  (interactive)
  (let ((archivo "/home/manuel/emacsTask.json"))
    (if (file-exists-p archivo)
        (let* ((json-object-type 'hash-table)
               (json-key-type 'string)
               (json-false 'nil)
               ;; Lee y parsea el archivo JSON
               (datos (json-read-file archivo))
               (ruta (gethash "path" datos))
               (comando (gethash "play" datos)))
          
          (if (and ruta comando)
              (progn
                ;; Cambia el directorio por defecto de Emacs a la ruta del JSON
                (let ((default-directory (file-name-as-directory ruta)))
                  ;; Abre la terminal (puedes usar 'ansi-term' o 'vterm' si lo prefieres)
                  (term "/bin/bash")
                  ;; Espera un breve momento a que la terminal cargue y envía el comando
                  (sleep-for 0.2)
                  (process-send-string (get-buffer-process (current-buffer)) 
                                       (concat comando "\n"))))
            (message "Error: No se encontró 'path' o 'cmd' en el archivo JSON.")))
      (message "Error: El archivo %s no existe." archivo))))

(defun my/dired-git-add-file ()
  "Ejecuta 'git add' sobre el archivo o directorio bajo el cursor en Dired."
  (interactive)
  (unless (eq major-mode 'dired-mode)
    (user-error "Esta función solo se puede usar dentro de Dired."))
  
  (let ((filename (dired-get-filename nil t)))
    (if filename
        (let ((output (shell-command-to-string 
                       (concat "git add " (shell-quote-argument filename)))))
          (message "git add: %s" (file-name-nondirectory filename))
          ;; Si usas dired-git-info o similar, esto refresca la vista
          (revert-buffer))
      (message "No hay ningún archivo bajo el cursor."))))

(with-eval-after-load 'dired
    (define-key dired-mode-map (kbd "j") #'buscar-dired)
    (define-key dired-mode-map (kbd "SPC") #'prev-buscar-dired)
    (define-key dired-mode-map (kbd "h") #'save-task-play)
    (define-key dired-mode-map (kbd "o") #'dired-next-line)     ; Baja una línea
    (define-key dired-mode-map (kbd "p") #'dired-previous-line) ; Sube una línea
    (define-key dired-mode-map (kbd "u") #'dired-up-directory)
    (define-key dired-mode-map (kbd "e") #'new-file-dired)
    (define-key dired-mode-map (kbd "r") #'renombrar-dired)
    (define-key dired-mode-map (kbd "k") #'my/dired-git-add-file)
    (define-key dired-mode-map (kbd "c") #'my/dired-copy-full-path)
    ;; para eliminar un file primero seleccionar con "d"
    ;; y luego Presionar "x" y escribe : yes
    ;; para eliminar un file con "D"
) 
;; traductor - google
(require 'url)

(defun traducir-a-espanol ()
  (interactive)
  (let* ((texto (read-string "Texto: "))
         (url (format
               "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=es&dt=t&q=%s"
               (url-hexify-string texto))))
    (with-current-buffer (url-retrieve-synchronously url)
      ;; Saltar las cabeceras HTTP
      (goto-char (point-min))
      (re-search-forward "^$")
      (forward-char)
 
      ;; Leer el JSON
      (let* ((json-array-type 'list)
             (json (json-read))
             (traduccion (car (car (car json)))))
        (kill-buffer (current-buffer))
        (message "Traducción: %s" traduccion)))))

(defun traducir-a-ingles ()
  (interactive)
  (let* ((texto (read-string "Texto : "))
         (url (format
               "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&q=%s"
               (url-hexify-string texto))))
    (with-current-buffer (url-retrieve-synchronously url)
      ;; Saltar las cabeceras HTTP
      (goto-char (point-min))
      (re-search-forward "^$")
      (forward-char)

      ;; Leer el JSON
      (let* ((json-array-type 'list)
             (json (json-read))
             (traduccion (car (car (car json)))))
        (kill-buffer (current-buffer))
        (message "Traducción: %s" traduccion)))))
;; line - select jump    

(defface sugerencia-face
  '((t (:foreground "#707070"
        :background "#bb9fd4"
        :weight bold)))
  "Cara para las etiquetas de line-jump.")

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

            ;; guardar relación char ? posición
            (puthash char pos label-map)

            ;; mostrar overlay
            (overlay-put ov 'before-string
                         (propertize (format " %c " char)
                                     'face 'sugerencia-face))
            (push ov overlays)

            (setq idx (1+ idx))))

        ;; Saltar folds correctamente
        (let ((ov (my-fold-overlay-at (point))))
        

          (if ov
              (goto-char (overlay-end ov)) ;; salto directo al final del fold
            (forward-line 1)))))

    (redisplay)

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
        (setq var-toggle 1)
        (let ((target (gethash (string-to-char input) label-map)))
          (when target
            (goto-char target))))

       ;; selección rango
       ((>= (length input) 2)
        (setq var-toggle 2)
	(setq select-mode 1)
        (let* ((start-pos (gethash (aref input 0) label-map))
               (end-pos   (gethash (aref input 1) label-map)))
          (when (and start-pos end-pos)
            (goto-char start-pos)
            (set-mark (point))
            (goto-char end-pos)
            (forward-line 1))))))))
	    
; blink vista actual    
(defvar line-jump-labels
'("a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m"
"n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y")
  "Teclas disponibles para etiquetar los saltos en la pantalla.")

(defun line-jump--build-groups (items)
  "Divide ITEMS en grupos etiquetados. Si excede, el resto va a la 'z'."
  (let ((groups (make-hash-table :test 'equal))
        (overflow nil)
        (labels-count (length line-jump-labels)))

    (dotimes (i (length items))
      (if (< i labels-count)
          (puthash (nth i line-jump-labels)
                   (list (nth i items))
                   groups)
        (push (nth i items) overflow)))

    (when overflow
      (puthash "z" (nreverse overflow) groups))

    groups))

(defun line-jump--draw-labels (groups)
  "Dibuja etiquetas temporales 'inline' (encima del texto) sin desplazarlo."
  (let ((overlays nil))
    (maphash
     (lambda (key items)
       ;; El desborde "z" se dibuja en todas las posiciones sobrantes
       (dolist (pos items)
         (let ((ov (make-overlay pos (min (1+ pos) (point-max)))))
           (overlay-put
            ov
            'display
            (propertize
             key
             'face 'sugerencia-face))
           (push ov overlays))))
     groups)
    overlays))

(defun line-jump--select-word (items)
  "Filtra recursivamente las posiciones en base a las teclas presionadas."
  (cond
   ((null items)
    nil)
   ((= (length items) 1)
    (goto-char (car items)))
   (t
    (let* ((groups (line-jump--build-groups items))
           (overlays (line-jump--draw-labels groups))
           (choices (mapcar #'string-to-char
                            (hash-table-keys groups)))
           (key (char-to-string
                 (read-char-choice
                  "Selecciona letra (z para más opciones): "
                  choices))))
      ;; Limpiar overlays de la ronda actual antes de la siguiente acción
      (mapc #'delete-overlay overlays)
      (let ((next-items (gethash key groups)))
        (when next-items
          (if (string= key "z")
              ;; Si se presionó 'z', pasamos recursivamente la lista sobrante
              (line-jump--select-word next-items)
            ;; Si se presionó cualquier otra letra, vamos directo o desempatamos
            (line-jump--select-word next-items))))))))

(defun line-jump--get-screen-matches (search-word)
  "Busca SEARCH-WORD únicamente en la parte visible de la pantalla actual."
  (setq var-toggle 1)
  (let ((starts nil)
        (start-pos (window-start))
        (end-pos (window-end)))
    (save-excursion
      (goto-char start-pos)
      ;; Buscamos la palabra exacta usando fronteras de palabra `\b`
      (while (re-search-forward (regexp-quote search-word) end-pos t)
        (push (match-beginning 0) starts)))
    (nreverse starts)))


(defvar palabra-view "")
(defun global-word-jump-screen ()
  "Pide una palabra al usuario y salta a sus coincidencias en la pantalla actual."
  (interactive)
  (let* ((target (read-string "Buscar palabra en pantalla: "))
         (matches (unless (string-empty-p target)
                    (line-jump--get-screen-matches target))))
    ;; Guardamos la búsqueda si no está vacía
    (unless (string-empty-p target)
      (setq palabra-view target))
    
    (if matches
        (line-jump--select-word matches)
      (message "No se encontraron coincidencias para '%s'." target))))

(defun older-jump-view ()
  "Vuelve a sugerir saltos para la última palabra que fue buscada."
  (interactive)
  (if (string-empty-p palabra-view)
      (message "No hay ninguna búsqueda anterior registrada.")
    (let ((matches (line-jump--get-screen-matches palabra-view)))
      (if matches
          (line-jump--select-word matches)
        (message "No se encontraron coincidencias visuales para '%s'." palabra-view)))))

;blink current line 
 (defvar line-jump-labels
'("a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m"
"n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y")
  "Teclas disponibles para etiquetar los saltos.")

(defun line-jump--build-groups (items)
  "Divide ITEMS en grupos etiquetados."
  (let ((groups (make-hash-table :test 'equal))
        (overflow nil)
        (labels-count (length line-jump-labels)))

    (dotimes (i (length items))
      (if (< i labels-count)
          (puthash (nth i line-jump-labels)
                   (list (nth i items))
                   groups)
        (push (nth i items) overflow)))

    (when overflow
      (puthash "z" (nreverse overflow) groups))

    groups))

(defun line-jump--draw-labels (groups)
  "Dibuja etiquetas temporales sobre el texto actual sin desplazarlo."
  (let ((overlays nil))
    (maphash
     (lambda (key items)
       (let* ((pos (car items))
              ;; El overlay ahora cubre exactamente 1 carácter de ancho
              (ov (make-overlay pos (1+ pos))))
         
         (overlay-put
          ov
          'display
          (propertize
           key
           'face 'sugerencia-face))
         
         (push ov overlays)))
     groups)
    overlays))
(defun line-jump--select-word (items)
  "Filtra recursivamente las posiciones."
  (cond
   ((null items)
    nil)
   ((= (length items) 1)
    (goto-char (car items)))
   (t
    (let* ((groups (line-jump--build-groups items))
           (overlays (line-jump--draw-labels groups))
           (choices (mapcar #'string-to-char
                            (hash-table-keys groups)))
           (key (char-to-string
                 (read-char-choice
                  "Selecciona: "
                  choices))))
      ;; Limpiar overlays siempre
      (mapc #'delete-overlay overlays)
      (let ((next-items (gethash key groups)))
        (when next-items
          (line-jump--select-word next-items)))))))

(defun line-jump--get-word-starts ()
  "Obtiene los inicios de palabra de la línea actual sin entrar en bucle infinito."
  (let ((starts nil)
        (end (line-end-position)))
    (save-excursion
      (beginning-of-line)
      (while (and (< (point) end)
                  (re-search-forward "\\_<" end t))
        (push (match-beginning 0) starts)
        ;; Forzar el avance para evitar el bucle infinito si la coincidencia es vacía
        (when (= (match-beginning 0) (match-end 0))
          (forward-char 1))))
    (nreverse starts)))

(defun line-word-jump ()
  "Salta a una palabra de la línea actual."
  (interactive)
  (let ((words (line-jump--get-word-starts)))
    (if words
        (line-jump--select-word words)
      (message "No se encontraron palabras."))))

;; vim mode 
(defvar var-toggle 1)
(defvar select-mode 0)
(defvar buscar-mode 0)
(defvar number-mode 0)
(defvar buscar-palabra "def")
(defun messages-mode (name)
  (setq-default mode-line-format
    (list
      (format " M %s | " name)
        " "
        mode-line-position
        " "
        mode-line-modes
    )
  )
) 
(setq-default truncate-lines t)
(defun alternar-mi-variable ()
  "Cambia el valor de var-toggle entre 1 y 2."
  (interactive)
  (setq var-toggle 1)
  (setq buscar-mode 0)
  (setq select-mode 0)
	(deactivate-mark)
   (messages-mode var-toggle))
(defun tab-variable ()
  (interactive)
  (cond
    ( (= var-toggle 0)
      (setq var-toggle 4)
   )
    ( (= var-toggle 4)   
      (setq var-toggle 0)
      (forward-char 1))
      
   )
   
 )

(defun enter-variable ()
  (interactive)
  (cond
	 ((= var-toggle 4)
		(let ((indent (current-indentation)))
			(newline)
			(newline)
			(indent-to (+ indent))
			(forward-line -1)
			(messages-mode 0)
			(indent-to (+ indent 4))
        )
        (setq var-toggle 0)
        )
     ((= var-toggle 0)
       (company-manual-begin))
     ((= var-toggle 1)
       (setq var-toggle 0)
       (mi-atajo-rapido)                         
     )
  )
   (messages-mode var-toggle)
)
(defun a-variable ()
  (interactive)
  (cond
    ( (= var-toggle 1)
      (setq var-toggle 0))
    ( (= var-toggle 0)
     (if (= number-mode 1)
        (setq number-mode 0)
      (progn
        (self-insert-command 1)
        )))
    ( (= var-toggle 4)
      (insert ":")     
      (setq var-toggle 0))
  )
   (messages-mode var-toggle)
)


(defun n-variable ()
  (interactive)
  (cond
  
    ( (= var-toggle 1)
		(seleccionar-simbolo-actual) 
		 (setq var-toggle 2)
		 (setq select-mode 1))
    ( (= var-toggle 2)
	   (setq var-toggle 1)          
       (tab-bar-close-tab))
     ((= var-toggle 0)
       (if (= number-mode 1)
        (insert "7")
      (progn
        (self-insert-command 1)
         )))
    ( (= var-toggle 4)
      (insert ">")     
      (setq var-toggle 0))
    )
   (messages-mode var-toggle)
 )
(defun m-variable ()
  (interactive)
  (cond
    ( (= var-toggle 1)
		 (other-window 1))
     ((= var-toggle 0)
       (if (= number-mode 1)
        (insert "8")
      (progn
        (self-insert-command 1)
        )))
    ( (= var-toggle 2)
      (split-window-below)
      (setq var-toggle 1))
    ( (= var-toggle 4)
      (insert "\\")     
      (setq var-toggle 0))
    )
   (messages-mode var-toggle)
 )

(defun i-variable ()
  (interactive)
  (cond  
    ( (= var-toggle 1)
      (setq var-toggle 2))
     ((= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
      (insert "+")     
      (setq var-toggle 0))
    )
   (messages-mode var-toggle)
 )
(defun r-variable ()
  (interactive)
  (cond
    ( (= var-toggle 1)
      (kill-whole-line)
      (message "cut"))
      ((= var-toggle 2)
          (kill-region (region-beginning) (region-end))
		  (deactivate-mark)
		  (setq var-toggle 1)
		  (setq select-mode 0)
      )
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
      (insert "()")     
      (backward-char 1)
      (setq var-toggle 0))
    )
   (messages-mode var-toggle)
 )


(defun v-variable ()
  (interactive)
  (cond
    ( (= var-toggle 2)
      (set-select-buscar))
    ( (= var-toggle 1)
	   (older-jump-view))
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
      (insert "*")     
      (setq var-toggle 0))
   ) 
   (messages-mode var-toggle)
) 
(defun g-variable ()
  (interactive)
  (cond
    ( (= var-toggle 1)
	   (next-line))
     ( (= var-toggle 0)
       (if (= number-mode 1)
        (insert "0")
      (progn
        (self-insert-command 1)
        )))
    ( (= var-toggle 4)
      (insert "{}")     
      (backward-char 1)
      (setq var-toggle 0))
   ) 
   (messages-mode var-toggle)
) 
(defun o-variable ()
  (interactive)
  (cond
    ( (= var-toggle 2)
      (delete-window))
    ( (= var-toggle 1)
	   (next-line))
     ( (= var-toggle 0)
       (if (= number-mode 1)
        (insert "5")
      (progn 
        (self-insert-command 1)
        )))
    ( (= var-toggle 4)
      (setq var-toggle 0)
      (mi-atajo-chars))
   ) 
   (messages-mode var-toggle)
 )
(defun p-variable ()
  (interactive)
  (cond
    ( (= var-toggle 1)
	     (previous-line))
     ( (= var-toggle 0)
      (if (= number-mode 1)
        (insert "4")
      (progn
        (self-insert-command 1)
        )))
    ( (= var-toggle 4)
      (insert "[]")     
      (backward-char 1)
      (setq var-toggle 0))
   ((= var-toggle 2)
    (indent-rigidly (region-beginning) (region-end) 4))
   ) 
   (messages-mode var-toggle)
 )
(defun t-variable ()
  (interactive)
  (cond
    ( (= var-toggle 1)
      (setq var-toggle 0)
      (global-word-jump-screen))
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
      (insert "-")     
      (setq var-toggle 0))
   ) 
   (messages-mode var-toggle)
 )
    
(defun s-variable ()
  (interactive)
  (cond
    ( (= var-toggle 1)
      (save-buffer) )
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
      (insert ".")     
      (setq var-toggle 0))
    ) 

   (messages-mode var-toggle)
    )
(defun u-variable ()
  (interactive)
  (cond
    ( (= var-toggle 1)
      (kill-new (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
     ( (= var-toggle 0)
       (if (= number-mode 1)
        (insert "6")
      (progn
        (self-insert-command 1)
        )))
    ( (= var-toggle 4)
      (insert ";")     
      (setq var-toggle 0))
	 ((= var-toggle 2)
		(when (use-region-p)
			(kill-ring-save (region-beginning) (region-end)) 
			(deactivate-mark))           
		(setq var-toggle 1)
		(setq select-mode 0))
    ) 
   (messages-mode var-toggle)
    )

(defun f-variable ()
  (interactive)
  (cond
	((or(= var-toggle 1)(= var-toggle 2))
	  	(setq var-toggle 0)
		(smart-jump-with-folds)
	)
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
      (insert "/")     
      (setq var-toggle 0))
    ) 

   (messages-mode var-toggle)
    )

(defun w-variable ()
  (interactive)
  (cond
    ( (= var-toggle 2)
    (on-buscar))
    ( (= var-toggle 1)
      (end-of-line)
      (newline)
     (insert (current-kill 0)))
     ( (= var-toggle 0)
      (self-insert-command 1))
    ((= var-toggle 4)
      (insert ",")     
      (setq var-toggle 0))
    ) 
   (messages-mode var-toggle)
    )

(defun e-variable ()
  (interactive)
  (cond
    ( (= var-toggle 1)
		(line-word-jump))
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
      (insert "$")     
      (setq var-toggle 0))
    ) 
   (messages-mode var-toggle)
)
(defun h-variable ()
  (interactive)
  (cond 
    ( (= var-toggle 2)
		(open-comands))          
    ( (= var-toggle 1)
		(ejecutar-term-task))
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
      (insert "?")
      (setq var-toggle 0))
    ) 
   (messages-mode var-toggle)
)

(defun y-variable ()
  (interactive)
  (cond 
    ( (= var-toggle 1)
		(ejecutar-term-play))
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
      (insert "$")     
      (setq var-toggle 0))
    ) 
   (messages-mode var-toggle)
)
(defun x-variable ()
  (interactive)
  (cond
    ( (= var-toggle 1)
		(kill-whole-line))
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
      (insert "&")     
      (setq var-toggle 0))
	 ((= var-toggle 2)
	   (call-interactively 'dired-jump)
	   (setq var-toggle 1)))
   (messages-mode var-toggle)
)
(defun j-variable ()
  (interactive)
  (cond
    ( (= var-toggle 1)
     (palabra-buscar))
     ( (= var-toggle 0)
       (if (= number-mode 1)
        (insert "3")
      (progn
        (self-insert-command 1)
        )))
    ( (= var-toggle 4)
      (setq number-mode 1)     
      (message "number-mode")
      (setq var-toggle 0))
    ) 
   (messages-mode var-toggle)
)
        
(defun q-variable ()
  (interactive)
  (cond
    ((and(= var-toggle 1)(= fold-mode 1))
          (show-subtree)) 
    ((and(= var-toggle 1)(= fold-mode 2))
       (hs-show-block))
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
     (insert "#")
     (setq var-toggle 0))
    ((and(= var-toggle 2)(= fold-mode 1))
      (show-all)
      (message "fold all")
      (setq var-toggle 1))
    ((and(= var-toggle 2)(= fold-mode 2))
       (hs-show-all)
       (setq var-toggle 1))
  )
   (messages-mode var-toggle)
)
(defun z-variable ()
  (interactive)
  (cond
    ((and(= var-toggle 1)(= fold-mode 1))
          (hide-subtree))
    ((and(= var-toggle 1)(= fold-mode 2))
       (hs-hide-block))
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
     (insert "<")
     (setq var-toggle 0))
    ((and(= var-toggle 2)(= fold-mode 1))
      (call-interactively 'my-fold-level)
      (setq var-toggle 1))
    ((and(= var-toggle 2)(= fold-mode 2))
       (hs-hide-all)
          (setq var-toggle 1))
  )
   (messages-mode var-toggle)
)
(defun c-variable ()
  (interactive)
  (cond 
    ( (= var-toggle 2)
     (setq var-toggle 2)
     (setq select-mode 1)
      (my-jump-and-select-to-saved-position))
    ( (= var-toggle 1)
     (my-select-from-saved-line)
     (setq var-toggle 2)
     (setq select-mode 1)
     )
     ( (= var-toggle 0)
      (self-insert-command 1))
    ( (= var-toggle 4)
     (insert "\"\"")     
  (backward-char 1)
  (setq var-toggle 0))
    ) 
   (messages-mode var-toggle)
    )
    
        
(defun d-variable ()
  (interactive)
  (cond
     ((= var-toggle 2)
      (setq var-toggle 1)
      (end-of-line))
     ( (= var-toggle 1)
     (my-save-current-line))
     ( (= var-toggle 0)
      (self-insert-command 1))
    ((= var-toggle 4)
     (insert "=")     
    (setq var-toggle 0))
  ) 
  (messages-mode var-toggle)
)
(defun b-variable ()
  (interactive)
  (cond
     ((= var-toggle 2)
      (setq var-toggle 1)
      (tab-bar-new-tab))
     ( (= var-toggle 1)
     (message "mode tab")
     (setq buscar-mode 2))
     ( (= var-toggle 0)
       (if (= number-mode 1)
        (insert "9")
      (progn
        (self-insert-command 1)
        )))
    ((= var-toggle 4)
     (insert "!")
    (setq var-toggle 0))
  ) 
  (messages-mode var-toggle)
)

(defun k-variable ()
  (interactive)
  (cond
     ((= var-toggle 1)
      (my-jump-to-saved-line))
     ((= var-toggle 2)
      (setq var-toggle 0)
      (call-interactively 'counsel-recentf))
     ( (= var-toggle 0)
       (if (= number-mode 1)
        (insert "2")
      (progn
        (self-insert-command 1)
        )))
     ( (= var-toggle 1)
     (setq buscar-mode 2))
    ((= var-toggle 4)
     (insert "_")     
    (setq var-toggle 0))
  ) 
  (messages-mode var-toggle)
)
(defun l-variable ()
  (interactive)
  (cond
   ((= var-toggle 1)
    (my-save-current-position))
   ((= var-toggle 2)
    (indent-rigidly (region-beginning) (region-end) -4))
   ((= var-toggle 0)
    (if (= number-mode 1)
        (insert "1")
      (progn
        (self-insert-command 1)
        )))
   
   ((= var-toggle 4)
     (insert "''")
     (backward-char 1)
    (setq var-toggle 0)))
  (messages-mode var-toggle))
(defun open-comands ()
    (interactive)
    (setq var-toggle 0)
    (execute-extended-command nil)
      (messages-mode var-toggle)
)
(defun xstar ()
    (interactive)
    (setq var-toggle 1)                
    (beginning-of-buffer)
      (messages-mode var-toggle)
)  
(defun xend ()
    (interactive)
    (setq var-toggle 1)
    (end-of-buffer)
      (messages-mode var-toggle)
) 

(defun xselectall()
    (interactive)
    (setq var-toggle 2)
    (setq select-mode 1)
    (mark-whole-buffer)
      (messages-mode var-toggle)
)
(global-set-key (kbd "<f2>") (lambda () (interactive) (load-file "~/.emacs")))
(defun xcopiar-ruta ()
  "Copiar al portapapeles la ruta completa del archivo del buffer actual."
  (interactive)
  (if buffer-file-name
      (progn
        (kill-new buffer-file-name)
        (message "Ruta copiada: %s" buffer-file-name))
    (message "Este buffer no está asociado a un archivo.")))
(defun palabra-buscar ()
  "Pide una palabra en el minibuffer. Presionar ESPACIO acepta y guarda la palabra en el buscador."
  (setq var-toggle 0)
  (interactive)
  (let ((map (copy-keymap minibuffer-local-map)))
    ;; Remapeamos la barra espaciadora para que actúe como ENTER (exit-minibuffer)

    (define-key minibuffer-local-map (kbd "SPC")
     (lambda ()
      (interactive)
      (exit-minibuffer)))
    ;; Pedimos la palabra usando nuestro mapa de teclado modificado
    (let ((palabra (read-from-minibuffer "Buscar : " nil map)))
      
      ;; Validamos  ue no esté vacía antes de guardarla
      (unless (string-empty-p palabra)
        
	(setq buscar-palabra palabra)
        (setq buscar-mode 1)
        (setq var-toggle 1)
        (message "buscar: '%s'" palabra)))))
(defun space-variable ()
  (interactive)
  (cond
    ((and(= var-toggle 1)(= buscar-mode 0))
     (undo))
	((= var-toggle 4)
		(let ((indent (current-indentation)))
			(end-of-line)
			(newline)
			(indent-to indent))
        (setq var-toggle 0))
     ((and (= var-toggle 1)(= buscar-mode 2))
      (tab-bar-switch-to-next-tab))
     ((and (= var-toggle 1)(= buscar-mode 1))
        (search-backward buscar-palabra))
     ( (= var-toggle 0)
      (self-insert-command 1))
	((= var-toggle 2)
		(scroll-down-command (/ (window-height) 2)))
    ) 

   (messages-mode var-toggle)
    )
(defun backspace-variable ()
  (interactive)
  (cond
    ((and (= var-toggle 1)(= buscar-mode 0 ))
     (undo-redo))
    ((and (= var-toggle 1)(= buscar-mode 2))
       (tab-bar-switch-to-prev-tab))
     ((and (= var-toggle 1)(= buscar-mode 1))
     (search-forward buscar-palabra))
     ((and (= var-toggle 2)(= select-mode 1))
	 		(when (use-region-p)
			(delete-region (region-beginning) (region-end))
			(deactivate-mark))
		(setq var-toggle 1)
		(setq select-mode 0))
	 ((and (= var-toggle 2)(= select-mode 0))
		 (scroll-up-command (/ (window-height) 2)))
     ((or (= var-toggle 0)(= var-toggle 4))
     (delete-backward-char 1) )

    ) 

   (messages-mode var-toggle)
    )    
(defun gion-variable ()     
    (interactive)
    (cond
     ((= var-toggle 0) 
        (backward-char 1) 
        (upcase-region (point) (1+ (point)))
        (forward-char 1)
     )
     ((= var-toggle 4) 
     (insert (current-kill 0))
      (setq var-toggle 0)
       )
      ((= var-toggle 1)
        (forward-char 1)
      )
    )
    (messages-mode var-toggle)
)

(add-hook 'c++-mode-hook
					(lambda ()
						(local-set-key (kbd ";") #'alternar-mi-variable)))
(add-hook 'java-mode-hook
          (lambda () 
            (local-set-key (kbd ";") #'alternar-mi-variable)))
;; Asigna esta función al atajo de teclado que tú quieras (por ejemplo: C-c q)
(global-set-key (kbd "SPC") 'space-variable)
(global-set-key (kbd "<backspace>") 'backspace-variable)
(global-set-key (kbd "d") 'd-variable)
(global-set-key (kbd "z") 'z-variable)
(global-set-key (kbd "h") 'h-variable)
(global-set-key (kbd "y") 'y-variable)
(global-set-key (kbd "q") 'q-variable)
(global-set-key (kbd "k") 'k-variable)
(global-set-key (kbd "l") 'l-variable)
(global-set-key (kbd "-") 'gion-variable)
(global-set-key (kbd "n") 'n-variable)
(global-set-key (kbd "m") 'm-variable)
(global-set-key (kbd "f") 'f-variable)
(global-set-key (kbd "w") 'w-variable)
(global-set-key (kbd "u") 'u-variable)
(global-set-key (kbd "s") 's-variable)
(global-set-key (kbd "c") 'c-variable)
(global-set-key (kbd "j") 'j-variable)
(global-set-key (kbd "t") 't-variable)  
(global-set-key (kbd "o") 'o-variable)  
(global-set-key (kbd "p") 'p-variable)  
(global-set-key (kbd "e") 'e-variable)  
(global-set-key (kbd "x") 'x-variable)  
(global-set-key (kbd ";") 'alternar-mi-variable)
(global-set-key (kbd "a") 'a-variable)
(global-set-key (kbd "r") 'r-variable)
(global-set-key (kbd "g") 'g-variable)
(global-set-key (kbd "v") 'v-variable)
(global-set-key (kbd "i") 'i-variable)
(global-set-key (kbd "b") 'b-variable)
(global-set-key (kbd "RET") 'enter-variable)
(global-set-key (kbd "<tab>") 'tab-variable)

;; git tools

(defun my/git-status-summary ()
  "Muestra la rama actual de Git y los archivos que están en el área de 'staging' (add)."
  (interactive)
  (let ((in-git-repo (zerop (call-process "git" nil nil nil "rev-parse" "--is-inside-work-tree"))))
    (if (not in-git-repo)
        (message "No estás dentro de un repositorio Git.")
      (let* ((branch (string-trim (shell-command-to-string "git branch --show-current")))
             (staged-files (string-trim (shell-command-to-string "git diff --cached --name-only")))
             (staged-list (if (string-empty-p staged-files)
                              "Ninguno"
                            (replace-regexp-in-string "\n" ", " staged-files))))
        (message "Rama: [%s] | Archivos en add: %s" branch staged-list)))))

(defun my/git-create-and-checkout-branch (branch-name)
  (interactive
   (let ((in-git-repo (zerop (call-process "git" nil nil nil "rev-parse" "--is-inside-work-tree"))))
     ;; 1. Si no hay repositorio Git, preguntar si se desea inicializar
     (unless in-git-repo
       (if (y-or-n-p "No hay un repositorio Git aquí. ¿Deseas ejecutar 'git init'? ")
           (progn
             (shell-command "git init")
             (message "Repositorio Git inicializado."))
         (user-error "Operación cancelada: Se requiere un repositorio Git.")))
     
     ;; 2. Pedir el nombre de la nueva rama
     (list (read-string "Nombre de la nueva rama: "))))

  ;; 3. Crear y cambiar a la rama con 'git checkout -b'
  (if (and branch-name (not (string-empty-p branch-name)))
      (let ((result (shell-command-to-string (concat "git checkout -b " (shell-quote-argument branch-name)))))
        (message "%s" (string-trim result)))
    (message "Nombre de rama no válido.")))


(defun my/git-commit-with-message (commit-msg)
  "Solicita un mensaje por el minibuffer y realiza un 'git commit -m'."
  (interactive
   (let ((in-git-repo (zerop (call-process "git" nil nil nil "rev-parse" "--is-inside-work-tree"))))
     (unless in-git-repo
       (user-error "Error: No estás dentro de un repositorio Git."))
     
     ;; Verificar si hay archivos agregados (staged)
     (let ((has-staged (not (string-empty-p 
                             (string-trim (shell-command-to-string "git diff --cached --name-only"))))))
       (unless has-staged
         (user-error "No hay archivos preparados ('git add') para hacer commit.")))
     
     ;; Pedir el mensaje
     (list (read-string "Mensaje del commit: "))))

  ;; Ejecutar el commit
  (if (and commit-msg (not (string-empty-p commit-msg)))
      (let ((result (shell-command-to-string 
                     (concat "git commit -m " (shell-quote-argument commit-msg)))))
        (message "%s" (string-trim result)))
    (message "Commit cancelado: el mensaje no puede estar vacío.")))


(defun mi-atajo-git ()
  (interactive)
  (message "git una letra : ")
 "Presiona una letra : "
  (let ((char (read-key))) ; Lee una tecla al instante sin pedir Enter
    (cond
     ((eq char ?i)
      (call-interactively 'my/git-create-and-checkout-branch))
     ((eq char ?t)
      (call-interactively 'my/git-status-summary))
     ((eq char ?v)
      (call-interactively 'my/git-commit-with-message))

     (t
      (message "Tecla '%c' no reconocida." char)))))

                   
;; packetes necesarios : (company - cape - iny) 
    
(use-package cape
  :ensure t)

(use-package company
  :ensure t
  :config
  (global-company-mode)                 
(recentf-mode 1)

;; IVY: El motor de completado interactivo
(use-package ivy
  :ensure t
  :init
  (ivy-mode 1))

;; COUNSEL: Trae comandos específicos que usan Ivy, incluyendo archivos recientes
(use-package counsel
  :ensure t
  :bind (("C-c r" . counsel-recentf))) ; <-- TU ATAJO AQUÍ
 
 
;; solo usar CAPF (donde está cape)
  (setq company-backends '(company-capf) 
        
        company-require-match nil
	
        company-idle-delay nil
        company-minimum-prefix-length 1))

;; SOLO palabras del buffer
(setq completion-at-point-functions
      (list #'cape-dabbrev))

(with-eval-after-load 'company
  (define-key company-active-map (kbd "TAB") nil)
  (define-key company-active-map (kbd "<tab>") nil))

;; ocultar con espacio
;(with-eval-after-load 'company
;  (define-key company-active-map (kbd "SPC") #'company-abort))
;; reemplazar CAPF en emacs-lisp-mode
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (setq-local completion-at-point-functions
                        (list #'cape-dabbrev))))
(setq-default completion-at-point-functions
              (list #'cape-dabbrev))
