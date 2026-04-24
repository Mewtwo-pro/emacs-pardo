
;; 1. Solo mostrar en la línea inferior
(setq eldoc-display-functions '(eldoc-display-in-echo-area))

;; 2. Evitar que los mensajes multilínea redimensionen bruscamente la línea inferior
(setq eldoc-echo-area-use-multiline-p nil) 

;; 3. Tu atajo de teclado
(global-set-key (kbd "C-x w") 'eldoc-print-current-symbol-info)


(use-package lsp-mode
  :hook ((c-mode c++-mode) . lsp)
  :config
  (setq lsp-clients-clangd-executable "clangd")


(setq lsp-diagnostics-provider :none)
(setq lsp-ui-sideline-enable nil)   ;; no mostrar errores en el costado
(setq lsp-ui-doc-enable nil)        ;; no mostrar popups de documentación
(setq lsp-modeline-diagnostics-enable nil)) ;; no mostrar conteo de errores en la mode-line


(setq lsp-headerline-breadcrumb-enable nil)

(require 'yasnippet)
(yas-global-mode 1)
