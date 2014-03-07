(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(c-basic-offset 4)
 '(c-default-style (quote ((c-mode . "bsd") (c++-mode . "bsd") (java-mode . "java") (awk-mode . "awk") (other . "gnu"))))
 '(indent-tabs-mode nil))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
(setq c-default-style "bsd"
      c-basic-offset 4)
(add-hook 'c-mode-common-hook
	  (lambda()
            (local-set-key (kbd "C-c o") 'ff-find-other-file)))
(custom-set-variables
 '(c-basic-offset 4))

(defun fontify-frame (frame)
;;  (set-frame-parameter frame 'font "Monospace-9"))
  (set-frame-parameter frame 'font "Droid Sans Mono-9"))

;; Fontify current frame
(fontify-frame nil)
;; Fontify any future frames
(push 'fontify-frame after-make-frame-functions)


(defun include-if-defs()
  (interactive)
  (let (def-symbol count len)
    (setq def-symbol (upcase (buffer-name)))
    (setq len (length def-symbol))
    (setq count 0)
    (while (< count len)
      (if (= (aref def-symbol count) ?.)
          (aset def-symbol count ?_))
      (if (= (aref def-symbol count) ?-)
          (aset def-symbol count ?_))
      (setq count (1+ count)))
    (insert "#ifndef _")(insert def-symbol)(insert "_\n")
    (insert "#define _")(insert def-symbol)(insert "_\n")
    ;; (insert "#endif  /* _")(insert def-symbol)(insert "_ */\n")))
    (insert "#endif")))