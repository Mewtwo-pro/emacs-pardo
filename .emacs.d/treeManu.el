(require 'imenu)
(defun mi/sugerir-clases-cpp ()
  "Busca clases en el archivo actual y muestra sus límites de línea."
  (interactive)
  (let* ((items (imenu--make-index-alist))
         ;; Filtramos solo las entradas que Imenu identifica como "Class" o similares
         (clases-alist (clist-filter-types items '("Class" "Classes" "struct")))
         (seleccion (completing-read "Selecciona una clase: " clases-alist nil t)))
    
    (when seleccion
      (let* ((marker (cdr (assoc seleccion clases-alist)))
             (linea-inicio (line-number-at-pos marker))
             (linea-fin (save-excursion
                          (goto-char marker)
                          (forward-list) ;; Salta hasta el cierre de la llave }
                          (line-number-at-pos))))
        (message "Clase: %s | Inicio: %d | Fin: %d" 
                 seleccion linea-inicio linea-fin)))))

(defun clist-filter-types (alist tipos)
  "Filtra el alist de imenu para obtener solo los tipos deseados."
  (let (resultado)
    (dolist (item alist resultado)
      (when (and (listp item) (member (car item) tipos))
        (setq resultado (append resultado (cdr item)))))))
  
(defun mi/enfocar-clase-cpp ()
  "Selecciona una clase del archivo actual y restringe la vista (narrow) a su definición."
  (interactive)
  (let* ((items (imenu--make-index-alist))
         ;; Filtramos para obtener las clases/structs del índice de Imenu
         (clases-alist (clist-filter-types items '("Class" "Classes" "struct")))
         (seleccion (completing-read "Enfocar clase: " clases-alist nil t)))
    
    (when seleccion
      (let* ((marker (cdr (assoc seleccion clases-alist)))
             (inicio (marker-position marker))
             (fin (save-excursion
                    (goto-char inicio)
                    ;; Buscamos la primera llave de apertura y saltamos al final del bloque
                    (re-search-forward "{")
                    (backward-char)
                    (forward-list)
                    (point))))
        
        (widen) ;; Limpiamos cualquier restricción previa
        (narrow-to-region inicio fin)
        (goto-char inicio)
        (message "Enfocado en: %s (Líneas %d a %d)" 
                 seleccion 
                 (line-number-at-pos inicio) 
                 (line-number-at-pos fin))))))

;; Función auxiliar para filtrar el índice (necesaria para que funcione)
(defun clist-filter-types (alist tipos)
  (let (resultado)
    (dolist (item alist resultado)
      (cond 
       ((and (listp item) (member (car item) tipos))
        (setq resultado (append resultado (cdr item))))
       ((and (listp item) (listp (cdr item))) ;; Maneja índices anidados
        (setq resultado (append resultado (clist-filter-types (cdr item) tipos))))))))
