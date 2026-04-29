;; 
(use-package avy
 :ensure t
	:bind
	(("C-:" . avy-goto-char)        ;; saltar a un carácter
	 ("C-'" . avy-goto-char-2)      ;; saltar a dos caracteres
	 ("M-g f" . avy-goto-line)      ;; saltar a una línea
	 ("M-g w" . avy-goto-word-1)))  ;; saltar a palabra
(defvar x-search "def")       
(defvar accion-buscar nil)
(defun pro-searh () 
		(interactive)
		(setq my-toggle-var 0)
		(define-key minibuffer-local-map (kbd "TAB")  
				(lambda ()
			(interactive)
			(setq my-toggle-var 4))
	) 
		(define-key minibuffer-local-map (kbd "SPC")
	(lambda ()
			(interactive)
			(setq buscar-contex 1)
			(setq my-toggle-var 1) 
			(setq accion-buscar 'buscar-on)
			(exit-minibuffer)
	) 
		)
		(let* ((name (read-string "buscar : ")))
	(pcase accion-buscar 
			('buscar-on 
				(setq x-search name) 
				(message "buscando : %s" x-search) 
			)
	)
	)
)

(defun buscar-palabra-word ()
	"Selecciona el simbolo completo donde esta el cursor."
	(interactive)
	(let ((word (thing-at-point 'symbol t))) 
			(setq x-search word) 
			(setq buscar-contex 1)
			(message "buscando : %s" word)))

(defvar xbuscar "g"
	"Carácter por defecto para `my-avy-goto-char-input`.")
(defvar set-caracter nil)

(defun pro-avi ()
	(interactive)
	;; Definimos la tecla directamente en el mapa del minibuffer
	(setq my-toggle-var 0)
	(define-key minibuffer-local-map (kbd "TAB")
		(lambda ()
			(interactive)
			(cond 
			  ((= my-toggle-var 0)
			  (setq my-toggle-var 4))
			  ((= my-toggle-var 4)
			   (forward-char)
                           (setq my-toggle-var 0))
			)))
	(define-key minibuffer-local-map (kbd "SPC")
			(lambda ()
		(interactive)
		(setq set-caracter 'go-caracter)
		(exit-minibuffer)
			)
	)
	;; Pedimos un input al usuario
	(let* ((name (read-string "caracter : ")))
		(pcase set-caracter 
		  ('go-caracter 
		    (setq xbuscar name)	  
		    (my-avy-goto-char-input)
		  )	
		)
	))

(defun my-set-xbuscar ()
	"Pide un carácter y lo guarda en `xbuscar`."
	(interactive)
	(setq xbuscar (string (read-char "Nuevo carácter: "))))

(defun my-avy-goto-char-input ()
	"Salta con avy usando el carácter guardado en `xbuscar`."
	(interactive)
	(avy-goto-char (string-to-char xbuscar)))
(defvar char-abajo "a")	
(defvar char-arriba "a")
(defun my-set-dos-letras ()
  "Pide una cadena y guarda las dos primeras letras en `xletra1` y `xletra2`."
  (interactive)
  	(define-key minibuffer-local-map (kbd "TAB")
		(lambda ()
			(interactive)
			(cond 
			  ((= my-toggle-var 0)
			  (setq my-toggle-var 4))
			  ((= my-toggle-var 4)
			   (forward-char)
                           (setq my-toggle-var 0))
			)))

  (let* ((entrada (read-string "Ingrese al menos dos letras: "))
         (len (length entrada)))
    (if (>= len 2)
        (progn
          (setq char-arriba (substring entrada 0 1))
          (setq char-abajo (substring entrada 1 2))
	  (setq my-toggle-var 2)
	  (messages-mode my-toggle-var)
	  (mi-seleccionar-rango-por-letras))
      (message "Debe ingresar al menos dos letras.")))) ;

(defun mi-seleccionar-rango-por-letras ()
  (interactive)
  (let ((pos-inicio) (pos-fin))
    (save-excursion
      ;; Buscar hacia atrás (arriba/izquierda)
      (if (search-backward char-arriba nil t)
          (setq pos-inicio (1+ (point)))
        (error "No se encontró la primera letra hacia atrás")))
    (save-excursion
      ;; Buscar hacia adelante (abajo/derecha)
      (if (search-forward char-abajo nil t)
          (setq pos-fin (1- (point)))
        (error "No se encontró la segunda letra hacia adelante")))
    
    ;; Establecer la marca y el punto para seleccionar el rango
    (goto-char pos-fin)
    (push-mark pos-inicio t t)))

;; Asignar a un atajo de teclado
(global-set-key (kbd "C-c s") 'mi-seleccionar-rango-por-letras)
