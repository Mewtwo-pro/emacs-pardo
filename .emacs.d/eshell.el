(require 'eshell) ;; Forzamos a que Emacs sepa qué es Eshell
(require 'json)
(defun task-eshell ()
  "Lee 'current' de data.json y muestra el primer elemento de la lista asociada."
  (interactive)
  (let* ((archivo "/home/manuel/.emacs.d/runTask.json")
         ;; 1. Leer el archivo
         (json-object (with-temp-buffer
                        (insert-file-contents archivo)
                        (json-read)))
         ;; 2. Obtener el nombre guardado en "current"
         ;; Usamos cdr para obtener el valor del par (current . "nombre")
         (nombre-clave (cdr (assq 'current json-object)))
         ;; 3. Buscar la lista asociada a ese nombre
         ;; Convertimos el string de nombre-clave a símbolo para buscarlo
         (lista-valores (cdr (assq (intern nombre-clave) json-object))))

    (if (and lista-valores (vectorp lista-valores) (> (length lista-valores) 0))
        (let ((primer-valor (elt lista-valores 0)))
	    (tab-bar-new-tab)
	    (term "/bin/bash") 
	    (term-send-string (get-buffer-process (current-buffer)) primer-valor)
	  )
      (message "No se encontró una lista válida para la clave: %s" nombre-clave)))
    (term-line-mode)
    (setq my-toggle-var 2)
    (messages-mode my-toggle-var)

      )

(defun copiar-ruta ()
  "Copiar al portapapeles la ruta completa del archivo del buffer actual."
  (interactive)
  (if buffer-file-name
      (progn
        (kill-new buffer-file-name)
        (message "Ruta copiada: %s" buffer-file-name))
    (message "Este buffer no está asociado a un archivo.")))

(defun mi-gestor-claves-json ()
  "Lee data.json, ofrece las claves en un menú (menos 'current') 
y actualiza 'current' con la elección."
  (interactive)
  (let* ((archivo "/home/manuel/.emacs.d/runTask.json")
	 ;; 1. Leer y parsear el JSON
	 (json-object (with-temp-buffer
			(insert-file-contents archivo)
			(json-read)))
	 ;; 2. Extraer las claves y filtrar "current"
	 (claves (mapcar 'symbol-name (mapcar 'car json-object)))
	 (claves-filtradas (remove "current" claves))
	 ;; 3. Mostrar el menú interactivo (input tipeando)
	 (eleccion (completing-read "Selecciona una clave: " claves-filtradas nil t)))
    ;; 4. Actualizar el valor de la clave "current"
    (setq json-object 
          (append `((current . ,eleccion)) 
                  (assq-delete-all 'current json-object)))

    ;; 5. Guardar los cambios con IDENTACIÓN
    (with-temp-file archivo
      (let ((json-encoding-pretty-print t)) ;; Activamos el modo "pretty-print"
        (insert (json-encode json-object))))	 
	 
    (message "Clave 'current' actualizada a: %s" eleccion)))
;; 
(defun my-insert-mode-eshell ()
  (interactive)
  (message "INSERT mode") 
  	(setq my-toggle-var 0)
   (messages-mode my-toggle-var))
;; 
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
(with-eval-after-load 'esh-mode ;; Nota: el nombre interno suele ser 'esh-mode'
  (define-key eshell-mode-map (kbd "<tab>") #'tab-simbol)
    (define-key eshell-mode-map (kbd "-") #'my-insert-mode-eshell))
(with-eval-after-load 'term
  (define-key term-raw-map (kbd ";") 'term-line-mode))
(add-hook 'term-mode-hook
  (lambda ()
    (define-key term-mode-map (kbd "`") 'term-char-mode)))
