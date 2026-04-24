; git commit machine
(require 'json)
(defvar path-git-work nil)
; git local tool

(defun relative-path-if-inside (file base)
  "Si FILE está dentro de BASE, retorna la ruta relativa.
   De lo contrario, retorna nil."
  (let ((truename-file (file-truename file))
        (truename-base (file-truename base)))
    (if (string-prefix-p truename-base truename-file)
        (file-relative-name truename-file truename-base)
      nil)))
(defun write-json-git (valor-x)
    (let* ((json-object-type 'hash-table)
	(json-array-type 'list)
	(file-git (format "%s/data_git.json" path-git-work) )
	(json-key-type 'string)
	(json-data (with-temp-buffer 
	    (insert-file-contents file-git)
	    (json-read)
	))
	(data-list (gethash "files_path" json-data))
        )
	(unless data-list 

	   (setq  data-list '())
	)
	(unless (member valor-x data-list)
	    (setq data-list (append data-list (list valor-x))))
	(puthash "files_path" data-list json-data)
	(with-temp-file file-git
	    (insert (json-encode json-data)))
	(message "%s , agregado :)" valor-x)
    )
    
)    
(defun set-file-to-git ()
    (interactive)
    (cond (path-git-work 
    (let ((file (dired-get-file-for-visit)))
	    (cond 
		((y-or-n-p (format "trabajaras con : %s" path-git-work))
		 (let  ((single-file (relative-path-if-inside file path-git-work)))
		     (if single-file 
			 (write-json-git single-file)
			 (message "no file in %s" path-git-work)
		     )
		 )
		)
		(t  (message "no agregado"))
		
	    )
	)				
    )
    (t  (message "no path git para trabajar :)"))
))
(defun crear-data-json-basico ()
  "Crea un archivo data.json con una estructura predefinida."
  (interactive)
  (let* ((file-path (format "%s/data_git.json" path-git-work))
         ;; Definimos la estructura del JSON como una lista asociativa
         (datos `((files_path . [])
                  (url_push . "manuel.com")))
         ;; Convertimos la lista a una cadena de texto JSON
         (json-string (json-encode datos)))
    
    ;; Escribimos la cadena en el archivo
    (with-temp-file file-path
      (insert json-string))
    
    (message "Archivo %s creado con éxito." file-path)))
(defun set-path-work ()
    (interactive)
    (let ((file (dired-get-file-for-visit)))
        (setq path-git-work (directory-file-name (file-name-directory file)))
	(if (y-or-n-p (format "set folder git : %s" path-git-work))
	    (message "%s guardado" path-git-work)
	    (message "no carpeta guardada")
	))
    
)

(defun nuevo-file ()
	(interactive)
	(setq my-toggle-var 0)
	(let ((map (copy-keymap minibuffer-local-map)))
		(define-key map (kbd "<tab>")
			(lambda ()
				(interactive)
				(setq my-toggle-var 4)))
		(let* ((dir (dired-current-directory))
	(filename (read-from-minibuffer "nombre del nuevo archivo: " nil map))
	(fullpath (expand-file-name filename dir)))
			(if (file-exists-p fullpath)
		(message "ya existe el archivo: %s" filename)
		(write-region "" nil fullpath)
		(revert-buffer)
		(message "archivo creado: %s" filename)
		(find-file fullpath)
		))))
(defun buscar-dired ()
    (interactive)
    	     (setq my-toggle-var 0)
	     (pro-searh))
(defun eliminar_file_sel()
  (interactive)
  (setq my-toggle-var 0)
  (dired-do-flagged-delete)
)
(with-eval-after-load 'dired
    (define-key dired-mode-map (kbd "s") #'set-file-to-git)
        (define-key dired-mode-map (kbd "SPC") #'my-next-match)
	(define-key dired-mode-map (kbd "TAB") #'my-prev-match)
    (define-key dired-mode-map (kbd "z") #'git-master-push)
    (define-key dired-mode-map (kbd "r") #'crear-data-json-basico)
    (define-key dired-mode-map (kbd "w") #'set-path-work)
    (define-key dired-mode-map (kbd "a") #'nuevo-file)    
    (define-key dired-mode-map (kbd "j") #'buscar-dired)
    (define-key dired-mode-map (kbd "k") 'dired-up-directory)
    (define-key dired-mode-map (kbd "x") #'eliminar_file_sel)
)
;;  ;;git-commit-local machine
(defun query-undo-git()
    (interactive)
    (cond ((y-or-n-p "retrocedemos al anterior commit ?")
           (ejecutar-comando-buffer-dir "git restore .")	
	   (message "regresamos al ultimo commit :)")
          )
	  (t  (git-add-local))
	  )
    
)
(defun check-git-init ()
   (interactive)
   (if (file-directory-p ".git")
       (query-undo-git)
       (create-git-init)
       
   )   
)
(defun create-git-init ()
    (interactive)
     	(cond ((y-or-n-p  "creamos git init?")
    	(ejecutar-comando-buffer-dir "git init") ;
	(git-add-local))
	(messages "no git init , bye")	;
	)
)

(defun git-add-local ()
  "Lee data_git.json y muestra si existe la clave files_path."
  (interactive)
  (cond
   ((y-or-n-p "asems add")
    (let* ((json-object-type 'alist) ;; importante para que sea un alist
           (json (json-read-file (concat default-directory "data_git.json"))) ;	
           (files (alist-get 'files_path json)))
      (if files
          (ejecutar-comando-buffer-dir
           (concat "git add " (mapconcat #'identity files " ")))
        (message "no existe valor %s" (concat default-directory "data_git.json"))))
    (git-commit-local)) ;; <- ahora está dentro de la misma rama
   (t
    (message "no add ,bye"))))	
(defun git-commit-local ()
    (interactive)
    (let* ((name (read-string "name commit : ")))
	(ejecutar-comando-buffer-dir (format "git commit -m \"%s\"" name))
	(message "nuevo commit creado :) , bye")
    )
)
; git push tool
(defun leer-json (ruta)
    (with-temp-buffer 
	(insert-file-contents ruta)
	(json-parse-buffer :object-type 'alist)
    )
)
(defun get-set-branch ()
    (interactive)
    (setq my-toggle-var 0)
    (let ((nombre (read-string "name branch : ")))
        (ejecutar-comando-buffer-dir (format "git checkout -b %s" nombre))
	(setq name_rama nombre)
	(git-add)
))

(defun git-add ()
  "Lee data_git.json y muestra si existe la clave files_path."
  (interactive)
  (cond
   ((y-or-n-p "asems add")
    (let* ((json-object-type 'alist) ;; importante para que sea un alist
           (json (json-read-file (concat default-directory "data_git.json"))) ;	
           (files (alist-get 'files_path json)))
      (if files
          (ejecutar-comando-buffer-dir
           (concat "git add " (mapconcat #'identity files " ")))
        (message "no existe valor %s" (concat default-directory "data_git.json"))))
    (git-commit)) ;; <- ahora está dentro de la misma rama
   (t
    (message "no add ,bye"))))


(defvar name_rama "manuel")        

(defun git-commit ()
  (interactive)
  (cond
   ((y-or-n-p (format "¿Hacemos commit con mensaje '%s'? " name_rama))
    (ejecutar-comando-buffer-dir (format "git commit -m \"%s\"" name_rama))
    (git-publicar-repo))
   (t
    (message "no commit, bye"))))

(defun git-publicar-repo ()
    (interactive)
    (cond
	((y-or-n-p "publicamos en git Hub")
	    (ejecutar-comando-buffer-dir (format "git push -u origin %s" name_rama))
            (delete-directory (concat default-directory ".git") t)
	    (message "publicado bye")
	    
	)
	(t (message "no push , bye"))
    )
    
)
(defun git-push()
  (interactive)    
     (let* ((json (leer-json (concat default-directory "data_git.json")))
	 (valor (alist-get 'url_push json)))
	 (if valor 
		  (cond
		     ((y-or-n-p "asemos push")
		      (ejecutar-comando-buffer-dir (format "git remote add origin %s" valor))
		      (get-set-branch))
		     (t   (message "no ardemos push")))	
        
	)))	
(defun git-init()
  (interactive)
  (let ((map (copy-keymap minibuffer-local-map)))
      (ejecutar-comando-buffer-dir "git init")
      (git-push)
   )
)
(defun git-master-push()
   (interactive)
   (let ((archivo (expand-file-name "data_git.json"  default-directory)))
      (if (file-exists-p archivo)
          (git-init)
          (message "no file data_git.json")) ;
   )
)

(defun ejecutar-comando-buffer-dir (cmd)
  "Ejecuta CMD en la carpeta del buffer actual."
  (let ((default-directory
         (if buffer-file-name
             (file-name-directory buffer-file-name)
           default-directory)))
    (shell-command cmd)))		
; atajos para grabar macros
;--> guardar credensiales user - tokken local :
;git config --global credential.helper store
;--> borrar credensiales para usar otra cuenta : 
;rm ~/.git-credentials
;rm ~/.config/git/credentials
