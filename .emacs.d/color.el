;edicion de colores para emacs

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))


(custom-set-faces
 '(rainbow-delimiters-depth-1-face ((t (:foreground "#ffffff" :weight bold)))) ; azul
 '(rainbow-delimiters-depth-2-face ((t (:foreground "#ffffff" :weight bold)))) ; violeta
 '(rainbow-delimiters-depth-3-face ((t (:foreground "#ffffff" :weight bold)))) ; turquesa
 '(rainbow-delimiters-depth-4-face ((t (:foreground "#ffffff" :weight bold)))) ; verde
 '(rainbow-delimiters-depth-5-face ((t (:foreground "#ffffff" :weight bold)))) ; rosado
 '(rainbow-delimiters-depth-6-face ((t (:foreground "#ffffff" :weight bold)))) ; amarillo
 '(rainbow-delimiters-depth-7-face ((t (:foreground "#ffffff" :weight bold)))))
