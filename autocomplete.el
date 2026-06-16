
(use-package cape
  :ensure t)

(use-package company
  :ensure t
  :config
  (global-company-mode)

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

;; forzar popup
(global-set-key (kbd "1") #'company-manual-begin)

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


