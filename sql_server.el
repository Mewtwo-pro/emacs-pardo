(defun ejecutar-sql-visor-inferior ()
  "Ejecuta sqlcmd y muestra el resultado en una ventana inferior partida."
  (save-buffer)
  (setq my-toggle-var 1)
  (messages-mode my-toggle-var)
  (interactive)
  (let* ((sql-file "/home/manuel/Documents/Sql/bufer.sql")
         (csv-path "/home/manuel/Documents/Sql/resultado.csv")
         (buffer-nombre "*Visor SQL*")
         (comando (list "sqlcmd" "-S" "localhost" "-U" "sa" "-P" "TuPasswordSeguro123!" 
                        "-i" sql-file "-s" "," "-W" "-o" csv-path)))
    
    ;; 1. Ejecutar sqlcmd
    (apply 'call-process (car comando) nil nil nil (cdr comando))

    ;; 2. Preparar el buffer
    (with-current-buffer (get-buffer-create buffer-nombre)
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert-file-contents csv-path)
        
        ;; Limpieza selectiva
        (goto-char (point-min))
        (delete-matching-lines "rows affected")
        (delete-matching-lines "Changed database")

        ;; Convertir a tabla de Org
        (org-mode)
        (goto-char (point-min))
        ;; Si el archivo está vacío, insertar aviso
        (if (= (buffer-size) 0)
            (insert "Comando ejecutado exitosamente (sin datos de retorno).")
          (org-table-convert-region (point-min) (point-max) '(4))
          (org-table-align))))

    ;; 3. Control de la ventana (Partición Horizontal Inferior)
    (let ((window (display-buffer-in-side-window 
                   (get-buffer buffer-nombre) 
                   '((side . bottom) (window-height . 0.3))))) ; 0.3 es el 30% de la pantalla
      (select-window window))))

;; Atajo de teclado sugerido
(global-set-key (kbd "<f5>") 'ejecutar-sql-visor-inferior)
