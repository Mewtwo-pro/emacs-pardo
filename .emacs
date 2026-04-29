;;; -*- lexical-binding: t -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(wombat))
 '(custom-safe-themes
   '("9b9d7a851a8e26f294e778e02c8df25c8a3b15170e6f9fd6965ac5f2544ef2a9" "456697e914823ee45365b843c89fbc79191fdbaff471b29aad9dcbe0ee1d5641" "77fff78cc13a2ff41ad0a8ba2f09e8efd3c7e16be20725606c095f9a19c24d3d" "d97ac0baa0b67be4f7523795621ea5096939a47e8b46378f79e78846e0e4ad3d" "e8bd9bbf6506afca133125b0be48b1f033b1c8647c628652ab7a2fe065c10ef0" "e4a702e262c3e3501dfe25091621fe12cd63c7845221687e36a79e17cf3a67e0" "7771c8496c10162220af0ca7b7e61459cb42d18c35ce272a63461c0fc1336015" "5c8a1b64431e03387348270f50470f64e28dfae0084d33108c33a81c1e126ad6" "4594d6b9753691142f02e67b8eb0fda7d12f6cc9f1299a49b819312d6addad1d" "7ec8fd456c0c117c99e3a3b16aaf09ed3fb91879f6601b1ea0eeaee9c6def5d9" "02d422e5b99f54bd4516d4157060b874d14552fe613ea7047c4a5cfa1288cf4f" default))
 '(font-use-system-font t)
 '(safe-local-variable-values '((lexicalinding . t)))
 '(tab-bar-mode t)
 '(tool-bar-mode nil))
(setq-default imenu-auto-rescan t)
 ;;  ;; If there is more than one, they won't work right.
(load "~/.emacs.d/lsp_info.el")
(load "~/.emacs.d/eshell.el")
(load "~/.emacs.d/pro_avi.el")
(load "~/.emacs.d/manuel.el") 
(load "~/.emacs.d/autocomplete.el")
(load "~/.emacs.d/color.el")
(load "~/.emacs.d/treeManu.el")
(load "~/.emacs.d/flashLine.el")
(load "~/.emacs.d/local_git.el")
(setq make-backup-files nil)      ;; Detener creación de archivos ~
(setq auto-save-default nil)       ;; Detener creación de archivos #...#
(setq create-lockfiles nil)        ;; Detener creación de archivos de bloqueo

(add-hook 'dired-mode-hook 'dired-hide-details-mode)
(use-package nerd-icons
	:ensure t)
(use-package nerd-icons-dired
	:ensure t
	:hook (dired-mode . nerd-icons-dired-mode))
	
;;plegado - fold	
(add-hook 'prog-mode-hook #'hs-minor-mode)
(add-hook 'mhtml-mode-hook (lambda () (hs-minor-mode -1)))
(add-hook 'html-mode-hook (lambda () (hs-minor-mode -1)))
  
(setq visible-bell t)
(setq ring-bell-function 'ignore)

(defun messages-mode (name)
	(setq-default mode-line-format
								(list
								 (format " M %s | " name)   ;; Aquí sí se inserta el valor
				
								 " "
								 mode-line-position
								 " "
								 mode-line-modes)))

;; Barra activa en negro con texto blanco
(set-face-attribute 'mode-line nil
    :background "black"
    :foreground "white"
    :box nil)

(setq-default truncate-lines t)
;; iostrar números de línea


 

;; Quitar barra de herramihentas
(tool-bar-mode -1)
;; Quitar menoú
(menu-bar-mode -1)
;; Quitar scroll
(scroll-bar-mode -1)
		
(setq inhibit-startup-screen t)
		
				
;; Habilitar repositorios
(require 'package)
(setq package-archives
			'(("gnu" . "https://elpa.gnu.org/packages/")
				("melpa" . "https://melpa.org/packages/")))

(use-package exec-path-from-shell
	:ensure t
	:config
	(exec-path-from-shell-initialize)
	(exec-path-from-shell-copy-envs '("PATH" "NODE_PATH")))

(defun cerrar-otros-buffers ()
	"Cierra todos los buffers excepto el actual."
	(interactive)
	(let ((actual (current-buffer)))
		(dolist (buf (buffer-list))
			(unless (eq buf actual)
				(kill-buffer buf)))))

(defvar mi-salto-busqueda nil)
(defvar mi-linea-guardada nil
	"Linea guardada para volver luego.")
(defun guardar-linea-actual ()
	"Guarda la linea actual del cursor."
	(interactive)
	(setq mi-linea-guardada (line-number-at-pos)))
(defun ir-a-linea-guardada ()
	"Salta a la linea previamente guardada." 
	(interactive)
	(if mi-linea-guardada
			(progn
				(goto-char (point-min))
				(forward-line (1- mi-linea-guardada)))
		(message "No hay linea guardada")))

;; Variable global para guardar la línea
(defvar my-saved-line nil
  "Línea guardada del cursor en el buffer actual.")

;; Función para guardar la línea actual
(defun my-save-current-line ()
  "Guarda la línea actual del cursor en `my-saved-line`."
  (interactive)
  (setq my-saved-line (line-number-at-pos))
  (message "Línea %d guardada" my-saved-line))

;; Función para seleccionar desde la línea guardada hasta la actual
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
		
;; Variable global para controlar el modo
(defvar my-toggle-var 0)
(defvar buscar-contex 0) 
;; Habilitar recentf
(require 'recentf)
(recentf-mode 1 )

;; Opcional: aumentar el número de archivos recordados
(setq recentf-max-saved-items  10 )

;; Guardar la lista cada vez que cierras un archivo o sales de Emacs
(add-hook 'kill-emacs-hook #'recentf-save-list)
(setq lsp-enable-symbol-highlighting nil)

(defvar mi-accion-salto nil)

(defun mi-salto-personalizado ()
	(interactive)
	(setq mi-salto-busqueda 0)
	(let ((map (copy-keymap minibuffer-local-map))
				(mi-accion-salto nil))

		;; bajar
		(define-key map (kbd "TAB")
			(lambda () (interactive)
				(setq mi-accion-salto 'abajo)
				(setq my-toggle-var 1)
				(exit-minibuffer)))
		;; subir
		(define-key map (kbd "SPC")
			(lambda () (interactive)		
				(setq mi-accion-salto 'arriba)
				(setq my-toggle-var 1)
				(exit-minibuffer)))
		;; absoluto
		(define-key map (kbd "RET") 
			(lambda () (interactive)
				(setq mi-accion-salto 'absoluto)
			 (setq my-toggle-var 1)
				(exit-minibuffer)))

		;; seleccionar arriba (lineas completas)
		(define-key map (kbd "w")
			(lambda () (interactive)
				(setq mi-accion-salto 'sel-arriba)
				(setq my-toggle-var 2)
				(exit-minibuffer)))

		;; seleccionar abajo (lineas completas)
		(define-key map (kbd "e")
			(lambda () (interactive)
				(setq mi-accion-salto 'sel-abajo)
				(setq my-toggle-var 2)
				(exit-minibuffer)))

		;; leer numero
		(let* ((num (string-to-number
								 (read-from-minibuffer "Numero: " nil map)))
					 (line-start (line-beginning-position))
					 (line-end (line-end-position)))

			(pcase mi-accion-salto
				('abajo
				 (forward-line num))

				('arriba
				 (forward-line (- num)))

				('absoluto
				 (goto-char (point-min))
				 (forward-line (1- num)))
	 
				 ('sel-arriba
				 (goto-char line-start)
				 (forward-line (- num))
				 (set-mark (line-end-position))
				 (goto-char line-end)
				 (activate-mark))
	 
				('sel-abajo	
				 (goto-char line-start)	
				 (set-mark line-start)
				 (forward-line num)
				 (goto-char (line-end-position))
				 (activate-mark))		

				(_ (message "No se eligioi accion")))))
	(messages-mode my-toggle-var)
	)

;; Alternar entre normal y navegación con ';'
(defun my-toggle ()
	(interactive)
	(cond
	  ((and (= my-toggle-var 1)(= buscar-contex 1)) 
	     (message "modo buscar desactivado")
		(setq buscar-contex 0))
	   (t
	(deactivate-mark)
	(setq my-toggle-var 1)))
   (messages-mode my-toggle-var))
;; Activar modo visual con SPACE (solo desde navegación)
(defun my-space-function ()  
	(interactive)  
	(cond
	((and (= my-toggle-var 1)(= buscar-contex 0))  
				(progn (undo)))
	((= my-toggle-var 4)
		(let ((indent (current-indentation)))
			(end-of-line)
			(newline)
			(indent-to indent))
		(setq my-toggle-var 0)(messages-mode my-toggle-var))
	((and (= my-toggle-var 1)(= buscar-contex 1))  
	 (my-prev-match)) 
	((= my-toggle-var 2)
		(scroll-down-command (/ (window-height) 2)))
	((= my-toggle-var 0)
			(insert " ")
	)
	(t	
		(messages-mode my-toggle-var))))
		

;; Funciones para q y w (scroll)

(defun my-q-function ()
	(interactive)
	(cond
	 ;; Si estamos en modo visual, copiar selección y volver a navegación

	 ((= my-toggle-var 1)
		(hs-hide-block)
		(message "fold"))
		
	 ((= my-toggle-var 4)
		(insert "#")
		(setq my-toggle-var 0))
		
	 ((= my-toggle-var 2)
		(hs-hide-all)
		(message "fold all")
		(setq my-toggle-var 1))
	 (t
		(insert "q")(company-manual-begin))))


(defun my-w-function ()
	(interactive)
	(cond
	 ;; Modo njavegación: pegar
	 ((= my-toggle-var 1)
		(yank)
		(message "Texto pegado"))
	((= my-toggle-var 2)
	  (newline)
	  (move-beginning-of-line 1)
	  (yank)
	  (setq my-toggle-var 1)
	  (messages-mode my-toggle-var))
	((= my-toggle-var 6) 
			(call-interactively 'kmacro-start-macro)
			(setq my-toggle-var 1)
			(messages-mode my-toggle-var)
	)      
	((= my-toggle-var 4)
		(insert ",")
		(setq my-toggle-var 0))
	 (t
		(insert "w")(company-manual-begin) )))
;; Movimiento con j k l y

(defun my-next-match ()
	(interactive)
			(search-forward x-search nil t))
(defun my-prev-match ()
	(interactive)
	(search-backward x-search nil t))

(defun my-p ()
	(interactive)
	(cond
	 ;; Modo 1 → como "e" en Vim (final de la palabra siguiente)
	 ((= my-toggle-var 1)
	     (previous-line)
	 )
	 ((= my-toggle-var 4)
		(insert "[]")       ; inserta dos comillas dobles
		(backward-char)
				(setq my-toggle-var 0))
	 ((= my-toggle-var 2)
             (indent-rigidly (region-beginning) (region-end) 4))
		 
	 ((= my-toggle-var 5)
		(insert "4"))
	 ;; Otros modos → insertar "o"
	 (t
		(insert "p") )))
		

(defun my-o ()
	(interactive)
	(cond
	 ((= my-toggle-var 2)
	   (mark-whole-buffer)
	 )
	 ((= my-toggle-var 1)
	   (next-line))
	 ;;             
	 ((= my-toggle-var 5)
		(insert "5"))
	 ((= my-toggle-var 4)
		(insert "@")
				(setq my-toggle-var 0))
	 ;; Otros modos → insertar "p"
	 (t
		(insert "o")(company-manual-begin) )))


(defun my-j ()
	(interactive)
	(cond
	 ((or(= my-toggle-var 1 )(= my-toggle-var 2))
	     (setq my-toggle-var 0)
	     (pro-searh))
	((= my-toggle-var 4)
		(insert "``")
				(setq my-toggle-var 0))
	 ((= my-toggle-var 5)
		(insert "3"))
	 ;; Normal → escribir "j"
	 (t (insert "j")(company-manual-begin)) ))

(defun my-k ()
	(interactive)
	(cond
	 ((= my-toggle-var 4)
		(insert "_")       ; inserta dos comillas dobles
	    (setq my-toggle-var 0))
	 ((= my-toggle-var 1)
	    (setq my-toggle-var 0)
	    (my-set-dos-letras)
	 )
	 ((= my-toggle-var 2)
				(call-interactively 'fzf-recentf)
				(setq my-toggle-var 1)(messages-mode my-toggle-var))
	 ((= my-toggle-var 5)
		(insert "2"))
	 ;; Normal → escribir "k"
	 (t (insert "k")(company-manual-begin)) ))
(defun my-y ()
	(interactive)
	(cond
	 ((= my-toggle-var 4) 
		(insert "%")
		(setq my-toggle-var 0))
	 ((= my-toggle-var 5)
		(insert "4"))
	 ((= my-toggle-var 0) (insert "y")(company-manual-begin)))
	  (messages-mode my-toggle-var))

(defun my-l ()
	(interactive)
	(cond
	 ((= my-toggle-var 1)
	  (setq my-toggle-var 0)
	  (call-interactively 'query-replace))

	 ((= my-toggle-var 2)
             (indent-rigidly (region-beginning) (region-end) -4))
	 ((= my-toggle-var 4)
		(insert "''")       ; inserta dos comillas dobles
		(backward-char)
		(setq my-toggle-var 0))
	 ((= my-toggle-var 5)
		(insert "1"))
	 (t (insert "l")(company-manual-begin))))

(defun my-h ()				; 
	(interactive)
	(cond
	 ((= my-toggle-var 4)
		(insert "?")
		(setq my-toggle-var 0))
	 ((= my-toggle-var 1)
	   (task-eshell)
	 )
	 ((= my-toggle-var 2)   
			(deactivate-mark)      (let ((word (thing-at-point 'symbol t)))
			(setq my-toggle-var 3)
			(if word
					(progn
						(isearch-mode t)
						(isearch-yank-string word)
						(message "Buscando palabra: %s (my-toggle-var = 3)" word))
			(message "No hay palabra bajo el cursor"))))
			
	 (t (insert "h")(company-manual-begin))))

(defun my-v-function ()
	(interactive)
	(cond
	 ((= my-toggle-var 1)
		(deactivate-mark)
		(my-avy-goto-char-input)
	 ) 	 
		
	 ((= my-toggle-var 4)
		(insert "*")
		(setq my-toggle-var 0))
	 (t
		(insert "v")(company-manual-begin))))

(defun my-g-function ()
	(interactive)
	(cond
	((= my-toggle-var 1)
	  (kill-line)
	)
	 ((= my-toggle-var 4)
		(insert "{}")
		(backward-char)
		(setq my-toggle-var 0))
	 ((= my-toggle-var 5)
		(insert "0"))
	 (t
		(insert "g")(company-manual-begin))))

(defun quitar-dos-guiones ()
	"Quita '--' al inicio de cada línea en la región seleccionada, si existen."
	(interactive)
	(save-excursion
		(let ((inicio (region-beginning))
					(fin (region-end)))
			(goto-char inicio)
			(while (< (point) fin)
				(beginning-of-line)
				(when (looking-at "^--")
					(delete-char 2)
					(setq fin (- fin 2))) ; ajustar el fin porque quitamos texto
				(forward-line 1)))))

(defun seleccionar-simbolo-actual ()
	"Selecciona el simbolo completo donde esta el cursor."
	(interactive)
	(let ((inicio (bounds-of-thing-at-point 'symbol)))
		(when inicio
			(goto-char (car inicio))
			(set-mark (cdr inicio))
			(activate-mark))))

;; Asignar Ctrl+1 a copiar (kill-ring-save)
(global-set-key (kbd "<f1>") 'kill-ring-save)

(defun my-a-function ()
	(interactive)
	(cond
        ((= my-toggle-var 2)
	 (setq my-toggle-var 1)
	 (messages-mode my-toggle-var)
	 (copiar-ruta))
	((= my-toggle-var 1)
	 (setq my-toggle-var 0)
	 (messages-mode my-toggle-var)
	 (call-interactively 'execute-extended-command)
	 )
       
	((= my-toggle-var 0)
	    (insert "a")(company-manual-begin)
	)
	 ((= my-toggle-var 4)
		(insert ":")
		(setq my-toggle-var 0))
	 (t
		(messages-mode my-toggle-var))))
	       
(defun my-d-function ()
	(interactive)
	(cond
	 ;; Modo 4: insertar "=" y volver a modo 0
	 ((= my-toggle-var 4)
		(insert "=")
		(setq my-toggle-var 0))
	((= my-toggle-var 1)
	  (my-save-current-line)
	)
							((= my-toggle-var 2)
								(deactivate-mark)                                ; desactiva selección
								(end-of-line)
								(setq my-toggle-var 1)
								(messages-mode my-toggle-var))

	 (t
		(insert "d")(company-manual-begin)  )))	
		
(defun my-e-function ()
	(interactive)
	(cond
	 ((= my-toggle-var 4)
		(insert "$")
		(setq my-toggle-var 0))

	 ;; Modo navegación: borrar toda la línea
	 ((= my-toggle-var 1)
		(backward-word))
	 ((= my-toggle-var 3)
		(check-git-init))
	 ;; Modo normal: insertar 'e'
	 (t
		(insert "e")(company-manual-begin)  )))

(defun my-backspace-function ()
		(interactive)
	(cond
	 ;; Modo visual: nueva línea con indentación
	 ((= my-toggle-var 1)
		(setq buscar-contex 0 )
	       	(setq my-toggle-var 2)
       		(messages-mode my-toggle-var))
	 ((= my-toggle-var 2)
		(when (use-region-p)
			(delete-region (region-beginning) (region-end))
			(deactivate-mark))
		(setq my-toggle-var 1)
		(message "Selección borrada, my-toggle-var = %d" my-toggle-var))

	 ;; Salto al final del buffer
	 ((= my-toggle-var 3)
		(setq my-toggle-var 1)
		(end-of-buffer)
		(message "Salto al final del buffer")) 

	 ;; Ejemplo de otro modo
	 ((= my-toggle-var 4)
		(setq my-toggle-var 5)
		(messages-mode my-toggle-var)
		(message "Modo mensajes activado")) 

	 ;; Por defecto: backspace normal
	 (t
		(backward-delete-char-untabify 1)
		(message "Backspace normal"))))
				 ;; Reemplaza el comportamiento de Backspace (DEL) en todos los buffers
(global-set-key [backspace] #'my-backspace-function)
(global-set-key (kbd "DEL") #'my-backspace-function)

(defun my-r-function ()
	(interactive)
	(cond
	 ((= my-toggle-var 5)
		(insert "0"))
	((= my-toggle-var 6) 
			(setq my-toggle-var 1)
			(messages-mode my-toggle-var)
			(call-interactively 'kmacro-end-and-call-macro)
			(setq my-toggle-var 1)
			(messages-mode my-toggle-var)
	)      
	 ;; Modo navegación: cerrar buffer como :q! en Vim
	 ((= my-toggle-var 1)
		(kill-buffer (current-buffer))
		(message "Buffer cerrado"))
	 
	 ;; Modo visual: insertar 'r'
	 ((= my-toggle-var 2)
		(insert "r"))
	 ((= my-toggle-var 4)
		(insert "()")
		(backward-char)
		(setq my-toggle-var 0))
	 ;; Modo normal: insertar 'r'
	 (t
		(insert "r")(company-manual-begin)  )))
(defun my-s-function ()
	(interactive)
	(cond
	 ;; Modo navegación: guardar buffer como :w! en Vim
	 ((= my-toggle-var 1)
		(save-buffer)
		(message "Buffer guardado"))
	 ((= my-toggle-var 4)
		(insert ".")
		(setq my-toggle-var 0))
	  ((= my-toggle-var 2)
	  (deactivate-mark)                                ; desactiva selección
	  (back-to-indentation)
	  (setq my-toggle-var 1)
	  (messages-mode my-toggle-var))

	 ((= my-toggle-var 3)
		(ir-a-linea-guardada)
		(setq my-toggle-var 1))
	 ;; Modo normal: insertar 's'
	 (t
		(insert "s")(company-manual-begin)  )))
(defun my-m-function () 
	(interactive)
			
	(cond
	 ;; Modo navegación: buscar palabra bajo cursor
	 ((= my-toggle-var 1)
	    (tab-bar-switch-to-next-tab)
	 )

	 ((= my-toggle-var 3)
			 (buscar-palabra-word)
	 )
	 ((= my-toggle-var 5)
		(insert "8"))
	 ((= my-toggle-var 6)
			(call-interactively 'eldoc-print-current-symbol-info)
	 )
	 ((= my-toggle-var 4)
		(insert "\\")
		(setq my-toggle-var 0))
		
	 (t
		(insert "m")(company-manual-begin)  )))

(defun my-t-function ()
	(interactive)
	(cond
	 ;; Si estamos en modo navegación, cambiar a modo 3

	 ((= my-toggle-var 7)
		(deactivate-mark)
		(my-avy-goto-char-input)
		(setq my-toggle-var 1)
		(messages-mode my-toggle-var)
	 ) 	 
        ((or(= my-toggle-var 1)(= my-toggle-var 2))
		(pro-avi)
		(setq my-toggle-var 1)
		(forward-char)
		(messages-mode my-toggle-var)
	 )
	 ((= my-toggle-var 4)
		(insert "-")
		(setq my-toggle-var 0))
	 (t
		(insert "t")(company-manual-begin)  )))
 
(defun my-n-function ()
	(interactive)
	(cond
	 ((= my-toggle-var 2)
	     (split-window-below)
	     (setq my-toggle-var 1)
	     (messages-mode my-toggle-var)
	 )
	 
	 ((= my-toggle-var 1)
		(seleccionar-simbolo-actual) 
		 (setq my-toggle-var 2))

	 ((= my-toggle-var 5)
		(insert "7"))
	 ((= my-toggle-var 4)
		(insert "|")
		(setq my-toggle-var 0))
	 (t
		(insert "n")(company-manual-begin)  )))
(defun my-u-function ()
	(interactive)
	(cond
		
	 ;; Si estamos en modo visual, copiar selección y volver a navegación
	 ((= my-toggle-var 2)
		(when (use-region-p)
			(kill-ring-save (region-beginning) (region-end)) ; copia al portapapeles
			(deactivate-mark))                                ; desactiva selección
		(setq my-toggle-var 1)
		(messages-mode my-toggle-var))
	 ;; Si estamos en modo navegación, hacer scroll
	 ((= my-toggle-var 1)
		(kill-new (string-trim-right (thing-at-point 'line t)))
		(message "Línea copiada al portapapeles"))
	((= my-toggle-var 5)
		(insert "6"))
	((= my-toggle-var 4)
		(insert ";")
		(setq my-toggle-var 0))
	 (t
		(insert "u")(company-manual-begin)  )))
(defun my-i ()				
	(interactive)
	(cond
	
	((= my-toggle-var 1)
	  (my-select-from-saved-line)
	  (setq my-toggle-var 2)
	  (messages-mode my-toggle-var)
	 )
	((= my-toggle-var 4)
		(insert "+")
		(setq my-toggle-var 0))
	((= my-toggle-var 3)
		(setq my-toggle-var 1)
		(cerrar-otros-buffers)
		(message "cerrado otros buffer"))
	((= my-toggle-var 5)
		(insert "6"))
	 (t
 (insert "i")(company-manual-begin))))

(defun my-tab-function ()  		;

	(interactive)
	(cond
	 ((= my-toggle-var 2)
		 (scroll-up-command (/ (window-height) 2))) 
	 ;; Casos: my-toggle-var = 3, 6 o 7 → resetear y mostrar mensaje
	 ((member my-toggle-var '(3 6 7))
		(setq my-toggle-var 1)
		(messages-mode my-toggle-var))
	 ((= my-toggle-var 4)
	    (forward-char)
            (setq my-toggle-var 0))
	 ((= my-toggle-var 5)
	     (setq my-toggle-var 4)
	     (messages-mode 0)
	 )
	 ((= my-toggle-var 0)	 
		(setq my-toggle-var 4))
	 ((and (= my-toggle-var 1)(= buscar-contex 1))
		(my-next-match)) 
	 ((and (= my-toggle-var 1)(= buscar-contex 0)) 
			(progn
			(if (fboundp 'undo-redo)
			(undo-redo))))
	
	 ;; Caso por defecto
	 (t
		(messages-mode my-toggle-var))))

				
(defun my-b-function ()
	(interactive)
	(cond
	 ((= my-toggle-var 5)
		(insert "9"))
	 ((= my-toggle-var 1)
	   	    (call-interactively 'other-window))
	 ((= my-toggle-var 2)
		(setq my-toggle-var 1)
		(tab-bar-new-tab)
		 (messages-mode my-toggle-var))
	 ((= my-toggle-var 4)
		(insert "!")
		(setq my-toggle-var 0))
	(t
		(insert "b")(company-manual-begin)  )))   ;; esto inserta un TAB real
(defun my-x-function ()
	(interactive)
	(cond
	 ;; En cualquier otro modo → inserta un tabulador
	 ((= my-toggle-var 1)
		(kill-whole-line)
		(message "Línea borrada")) 
	 ((= my-toggle-var 2)
	   (call-interactively 'dired-jump)
	   (setq my-toggle-var 1)
	   (messages-mode my-toggle-var)
	 )
	 ((= my-toggle-var 4)
		(insert "&")
		(setq my-toggle-var 0))
	 (t						;
		(insert "x")(company-manual-begin)  )))   ;; esto inserta un TAB real
(defun my-z-function ()
	(interactive)
	(cond
	 ((= my-toggle-var 1)
	    (message "unfold")(hs-show-block))
	 ((= my-toggle-var 2 )
		(hs-show-all)
		(message "unfold all")
		(setq my-toggle-var 1))

	 ;; En cualquier otro modo → inserta un tabulador
	 ((= my-toggle-var 4)
		(insert "<>")
		(backward-char)
		(setq my-toggle-var 0))
	 (t
		(insert "z")(company-manual-begin)  )))   ;; esto inserta un TAB real
				 
(defun my-f-function ()		       
	(interactive)
	(cond
	((or(= my-toggle-var 1)(= my-toggle-var 2))
	  	(setq my-toggle-var 0)
		(messages-mode my-toggle-var)
		(smart-jump-with-folds)
	)
      	 ((= my-toggle-var 4)
		(insert "/")
		(setq my-toggle-var 0))
	 (t
		(insert "f")(company-manual-begin)  )))   ;; esto inserta un TAB real

(defun my-enter-funcion ()
	(interactive)
	(cond
	 ;; En cualquier otro modo → inserta un tabulador
	((or(= my-toggle-var 1)(= my-toggle-var 2))
	   (setq my-toggle-var 0)
	   (setq buscar-contex 0)
	   (messages-mode my-toggle-var)
	   )
	 ((= my-toggle-var 4)
		(let ((indent (current-indentation)))
			(newline)
			(newline)
			(indent-to (+ indent))
			(forward-line -1)
			(setq my-toggle-var 0)
			(indent-to (+ indent 2))
			(message "Saltos agregados, cursor arriba y movido 4 espacios")))
	(t
			(company-manual-begin))))
(defun my-c-function ()
	(interactive)
	(cond
	 ;; En cualquier otro modo → inserta un tabulador
	((= my-toggle-var 1)
	    (tab-bar-close-tab)
	)
	((= my-toggle-var 2)
		(setq my-toggle-var 1)
		(messages-mode my-toggle-var)
		(delete-window))
	 ((= my-toggle-var 4)
		(insert "\"\"")
		(backward-char)
		(setq my-toggle-var 0))
	 (t
	 (insert "c") (company-manual-begin))))   ;; esto inserta un TAB real

(add-hook 'c++-mode-hook
					(lambda ()
						(local-set-key (kbd ";") #'my-toggle)))
;; Atajos de teclado
(global-set-key (kbd "TAB") #'my-tab-function)
(global-set-key (kbd "m") #'my-m-function)
(global-set-key (kbd "c") #'my-c-function)
(global-set-key (kbd "z") #'my-z-function)
(global-set-key (kbd "x") #'my-x-function)
(global-set-key (kbd "b") #'my-b-function)
(global-set-key (kbd "u") #'my-u-function)
(global-set-key (kbd "t") #'my-t-function)
(global-set-key (kbd "s") #'my-s-function)
(global-set-key (kbd "r") #'my-r-function)
(global-set-key (kbd "e") #'my-e-function)
(global-set-key (kbd "a") #'my-a-function)
(global-set-key (kbd "d") #'my-d-function)
(global-set-key (kbd "f") #'my-f-function)
(global-set-key (kbd "n") #'my-n-function)
(global-set-key (kbd ";") #'my-toggle)
(global-set-key (kbd "q") #'my-q-function)
(global-set-key (kbd "w") #'my-w-function)
(global-set-key (kbd "j") #'my-j)
(global-set-key (kbd "i") #'my-i)
(global-set-key (kbd "y") #'my-y)
(global-set-key (kbd "p") #'my-p)
(global-set-key (kbd "o") #'my-o)
(global-set-key (kbd "k") #'my-k)
(global-set-key (kbd "l") #'my-l)
(global-set-key (kbd "h") #'my-h)
(global-set-key (kbd "SPC") #'my-space-function)
(global-set-key (kbd "g") #'my-g-function)
(global-set-key (kbd "RET") #'my-enter-funcion)
(global-set-key (kbd "v") #'my-v-function)

(add-hook 'isearch-mode-hook
					(lambda ()
						(define-key isearch-mode-map (kbd "t") (lambda () (interactive) (t-buscar)))
						(define-key isearch-mode-map (kbd "w") (lambda () (interactive) (w-buscar)))
						(define-key isearch-mode-map (kbd "v") (lambda () (interactive) (v-buscar)))
						(define-key isearch-mode-map (kbd "u") (lambda () (interactive) (u-buscar)))
						(define-key isearch-mode-map (kbd "r") (lambda () (interactive) (r-buscar)))
						(define-key isearch-mode-map (kbd "a") (lambda () (interactive) (a-buscar)))
						(define-key isearch-mode-map (kbd "s") (lambda () (interactive) (s-buscar)))
						(define-key isearch-mode-map (kbd "f") (lambda () (interactive) (f-buscar)))
						(define-key isearch-mode-map (kbd "d") (lambda () (interactive) (d-buscar)))
						(define-key isearch-mode-map (kbd "z") (lambda () (interactive) (z-buscar)))
						(define-key isearch-mode-map (kbd "x") (lambda () (interactive) (x-buscar)))
						(define-key isearch-mode-map (kbd "c") (lambda () (interactive) (c-buscar)))
						(define-key isearch-mode-map (kbd "n") (lambda () (interactive) (n-buscar)))
						(define-key isearch-mode-map (kbd "m") (lambda () (interactive) (m-buscar)))
						(define-key isearch-mode-map (kbd "b") (lambda () (interactive) (b-buscar)))
						(define-key isearch-mode-map (kbd "o") (lambda () (interactive) (o-buscar)))
						(define-key isearch-mode-map (kbd "l") (lambda () (interactive) (l-buscar)))
						(define-key isearch-mode-map (kbd "g") (lambda () (interactive) (g-buscar)))
						(define-key isearch-mode-map (kbd "q") (lambda () (interactive) (q-buscar)))
						(define-key isearch-mode-map (kbd "j") (lambda () (interactive) (j-buscar)))
						(define-key isearch-mode-map (kbd "h") (lambda () (interactive) (h-buscar)))
						(define-key isearch-mode-map (kbd "y") (lambda () (interactive) (y-buscar)))
						(define-key isearch-mode-map (kbd "h") (lambda () (interactive) (h-buscar)))
						(define-key isearch-mode-map (kbd "k") (lambda () (interactive) (k-buscar)))
						(define-key isearch-mode-map (kbd "p") (lambda () (interactive) (p-buscar)))))


(defun k-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "_")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "k"))
		)
)
(defun h-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "?")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "h"))
		)
)	    	    
(defun y-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "%")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "y"))
		)
)	    	    
						
(defun q-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "#")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "q"))
		)
)	    	    
			
(defun j-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "``")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "j"))
		)
)	    	    
			
(defun g-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "{}")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "g"))
		)
)	    	    
			
(defun l-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "''")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "l"))
		)
)	    	    

(defun o-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "@")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "o"))
		)
)	    	    

(defun b-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "!")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "b"))
		)
)	    	    

(defun m-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "|")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "m"))
		)
)	    	    
(defun n-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "\\")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "n"))
		)
)
			
(defun c-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "\"\"")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "c"))
		)
)

(defun x-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "&")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "x"))
		)
)

(defun z-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "<>")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "z"))
		)
)
(defun f-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "/")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "f"))
		)
)
(defun d-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "=")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "d"))
		)
)

(defun s-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string ".")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "s"))
		)
)	    	  
(defun a-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string ":")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "a"))
		)
)	    	    

(defun r-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "()")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "r"))
		)
)	    
(defun w-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string ",")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "w"))
		)
)	    
(defun e-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "$")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "e"))
		)
)	    
(defun p-buscar ()
	"Activa el modo 6 y muestra un mensaje."
	(interactive)
	(cond
	 ((= my-toggle-var 4)
		(isearch-yank-string "[]")
		(setq my-toggle-var 0))
	 ((= my-toggle-var 0)
	 (isearch-yank-string "p")))
	 )
(defun u-buscar ()
	(interactive)
	(cond
	 ((= my-toggle-var 4)
		(isearch-yank-string ";")
		(setq my-toggle-var 0))
	 ((= my-toggle-var 0)
	 (isearch-yank-string "u")))
	 )
(defun t-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "-")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "t"))
		)
)
(defun v-buscar ()
		(interactive)
				(cond
				((= my-toggle-var 4)
				(isearch-yank-string "*")
				(setq my-toggle-var 0))
				((= my-toggle-var 0)
				(isearch-yank-string "v"))
		)
)					
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "JetBrainsMono Nerd Font Propo" :foundry "JB" :slant normal :weight regular :height 203 :width normal))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "#ffffff" :weight bold))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "#ffffff" :weight bold))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "#ffffff" :weight bold))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "#ffffff" :weight bold))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "#ffffff" :weight bold))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "#ffffff" :weight bold))))
 '(rainbow-delimiters-depth-7-face ((t (:foreground "#ffffff" :weight bold)))))
