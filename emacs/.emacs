(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(c-basic-offset 4)
 '(c-default-style (quote ((c-mode . "bsd") (c++-mode . "bsd") (java-mode . "java") (awk-mode . "awk") (other . "gnu"))))
 '(indent-tabs-mode nil)
 '(tab-stop-list (4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 96 104 112 120)))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )


;;
;; Font size
;;
(defun fontify-frame (frame)
  (set-frame-parameter frame 'font "Monospace-10"))

;; Fontify current frame
(fontify-frame nil)
;; Fontify any future frames
(push 'fontify-frame after-make-frame-functions)

;;
;; Full path in title bar
;;
(setq-default frame-title-format "%b (%f)")

;;
;; Show column number
;;
(setq column-number-mode t)

;;
;; Coding styles
;;
(setq c-default-style "bsd"
      c-basic-offset 4)
(add-hook 'c-mode-common-hook
	  (lambda()
            (local-set-key (kbd "C-c o") 'ff-find-other-file)))
(custom-set-variables
 '(c-basic-offset 4))

(setq default-tab-width 4)

;; Custom configuration scripts
(add-to-list 'load-path "~/bin")

;; VB mode
(autoload 'visual-basic-mode "visual-basic-mode" "Visual Basic mode." t)
(setq auto-mode-alist (append '(("\\.\\(frm\\|bas\\|cls\\)$" .
                                 visual-basic-mode)) auto-mode-alist))

;; VB.NET mode
(autoload 'vbnet-mode "vbnet-mode" "Mode for editing VB.NET code." t)
(setq auto-mode-alist (append '(("\\.\\(frm\\|bas\\|cls\\|vb\\)$" .
                                 vbnet-mode)) auto-mode-alist))
;;
;;  Optionally, add a mode-hook function.  To do so, use something
;;  like this to your .emacs file:
;;
(defun my-vbnet-mode-fn ()
  "My hook for VB.NET mode"
  (interactive)
  ;; This is an example only.
  ;; These statements are not required to use VB.NET, but
  ;; you might like them.
  (turn-on-font-lock)
  (turn-on-auto-revert-mode)
  (setq indent-tabs-mode nil)
  (require 'flymake)
  (flymake-mode 1)
  ;; ...other mode-setup code here...
  )
(add-hook 'vbnet-mode-hook 'my-vbnet-mode-fn)

;; Graphviz mode
(load-file "~/.emacs.d/graphviz-dot-mode.el")


;;
;; Rsync hook post-save
;;
(defun rsync-post-save()
  (interactive)
  (setq layout (current-window-configuration))
  (message "Synchronising...")
  (async-shell-command (concat "python ~/bin/rsyncall.py " (buffer-file-name)) nil nil)
  (set-window-configuration layout))

(add-hook 'after-save-hook 'rsync-post-save)

;;
;; Macros
;;
(defun sirca-include-if-defs()
  (interactive)
  (let (def-symbol count len buff)
    (setq buff (buffer-name))
    (setq len (length buff))
    (setq count 0)
    (setq def-symbol nil)
    (while (< count len)
      (if (and (>= (aref buff count) ?a)
               (<= (aref buff count) ?z))
          (setq def-symbol (concat def-symbol (string (upcase (aref buff count))))))
      (if (and (>= (aref buff count) ?A)
               (<= (aref buff count) ?Z))
          (progn (setq def-symbol (concat def-symbol "_"))
                 (setq def-symbol (concat def-symbol (string (aref buff count))))))
      (if (or (= (aref buff count) ?.)
              (= (aref buff count) ?-))
          (setq def-symbol (concat def-symbol "_")))
      (setq count (1+ count)))
    (insert "#ifndef ")(insert def-symbol)(insert "_\n")
    (insert "#define ")(insert def-symbol)(insert "_\n")
    (insert "#endif")))

;;(defun sirca-search-back-for-sr()
;;  (let (sr-point)

;; Instrument with C-u C-M-x
(defun trim-spaces(str)
  "Trims leading and trailing spaces from a string"
  (let (outstr)
    (setq outstr str)
    (if (= (aref outstr 0) ?\s)
        (setq outstr (trim-spaces (substring outstr 1))))
    (if (= (aref outstr (- (length outstr) 1)) ?\s)
        (setq outstr (trim-spaces (substring outstr 0 -1))))
    outstr))

(defun bounded-value-search(keyword stop-search-pattern default extractfn)
  "Generic key-value search bounded by a search pattern"
  (let (edit-point heading-point sr-point end-line-point)
    (setq edit-point (point))
    (re-search-backward stop-search-pattern)
    (setq heading-point (point))
    (goto-char edit-point)
    (re-search-backward keyword)
    (setq sr-point (funcall extractfn (point) keyword))
    (setq end-line-point (line-end-position))
    (goto-char edit-point)
    (if (> sr-point heading-point)
        (buffer-substring sr-point end-line-point)
      default)))

(defun get-current-sr(stop-search-pattern)
  "Gets the Service Request label for the section bounded upwards by the given search pattern"
  (trim-spaces (bounded-value-search "Service Request:"
                                     stop-search-pattern
                                     "x-xxxxxxxxxxx"
                                     (lambda (pt kw) (+ pt (length kw))) )))

(defun get-client(stop-search-pattern)
  "Gets the client name for the section bounded upwards by the given search pattern"
  (trim-spaces (bounded-value-search "Dear .*,"
                                     stop-search-pattern
                                     "[Client],"
                                     (lambda (pt kw) (+ pt 5) ) )))

(defun get-today()
  (trim-spaces (format-time-string "%e %b %Y")))

(defun get-day-in-one-week()
  "Get a dd MMM YYYY format date string for one week from now"
  (trim-spaces (format-time-string "%e %b %Y" (time-add (current-time)
                                                        (days-to-time 7)))))

(defun siebel-num-length-verify(sr)
  (if (and (= (length sr) 13)
           (= (aref sr 1) ?-))
      sr
    (concat sr " [CHECK]")))

(defun get-sr-for-close-message(sr)
  (if (and (= (length sr) 13)
           (= (aref sr 1) ?-))
           ;;(= (string-match "[0-9]-[0-9]\{11\}" sr) 0))
      (concat "SR " sr)
    "this service request"))

;;
;; Wish list:
;; - [X] Auto generate the close date (1 week from today)
;;       See: http://stackoverflow.com/questions/4242012/how-do-i-add-dates-in-emacs-using-emacs-lisp
;; - [X] Fix the default SR value issue
;; - [X] Get the default SR by searching backwards through the buffer, stopping at the first org-mode heading encountered
;; - [X] Auto grab the client's name
;; - [ ] Verify the x-xxxxxxxxxxx format (1 dash 11 numbers)
;;
(defun sirca-sr-template(sr)
  "Insert SIRCA SR email template"
  (interactive "MSiebel Request number [auto]: ")
  (let (sr-trimmed sr-found)
    (if (= (length sr) 0)
        (setq sr-trimmed (get-current-sr "^\*\* [Ss][Rr]"))
      (setq sr-trimmed (trim-spaces sr)))
    (insert "#+BEGIN_EXAMPLE\n")
    (insert "Service Request: " (siebel-num-length-verify sr-trimmed) "\n")
    (insert "Dear " (get-client "^\*\* [Ss][Rr]") "\n")
    (insert "## New issue ##\n")
    (insert "My name is Matthew Dalton and I will be investigating the issue you are having with [Summary of issue].\n")
    (insert "## Issue take-over ##\n")
    (insert "My name is Matthew Dalton and I have taken over the issue you are having with [Summary of issue] from Leo/Nhut.\n")
    (insert "\n")
    (insert "## Issue needs to remain open ##\n")
    (insert "Please note " (get-sr-for-close-message sr-trimmed) " will be closed if no correspondence is received before " (get-day-in-one-week) ".\n")
    (insert "## Issue can be closed ##\n")
    (insert "Please advise if " (get-sr-for-close-message sr-trimmed) " can be closed. TRTH requests that feedback be provided on or before " (get-day-in-one-week) ", at which point, if no confirmation is received, the SR will be CLOSED.\n")
    (insert)
    (insert "Regards,\n")
    (insert "Matthew Dalton\n")
    (insert "Thomson Reuters Tick History Technical Support\n")
    (insert "#+END_EXAMPLE\n")))

(defun sirca-quota-reset-template(client_id)
  (interactive "MClient id [0000]:")
  (insert "*** Requested Change\n")
  (insert "As requested in SR-xxxx.\n")
  (insert "Thomson Reuters has requested that we reset the quota for [Client]\n")
  (insert "Their present usage is:\n")
  (insert "  [insert usage here]\n")
  (insert "*** Solution design\n")
  (insert "Change the UMS database to reset the quota for this client.\n")
  (insert "We need to modify UMS for client_id = " client_id "\n")
  (insert "Please see planning steps.\n")
  (insert "*** Deployment Plan\n")
  (insert "1) Backup following following table using MYSQL Dump: ClientRICUsage, ClientRICUsageFree, Client for client_id = " client_id "

Firstly use below command to back up the RICs charged for this client and attach the generated files to this CR.
{code}
mysqldump -u<username> -p<password> --skip-lock-tables -hcastle-db-ums  --no-create-db --no-create-info -w\"client_id=" client_id "\" ums ClientRICUsage > sql_ClientRICUsage.dump
mysqldump -u<username> -p<password> --skip-lock-tables -hcastle-db-ums  --no-create-db --no-create-info -w\"client_id=" client_id "\" ums ClientRICUsageFree > sql_ClientRICUsageFree.dump
mysqldump -u<username> -p<password> --skip-lock-tables -hcastle-db-ums  --no-create-db --no-create-info -w\"id=" client_id "\" ums Client > sql_Client.dump
{code}
Attach the backup files to this Change Request.

2)
Run the following on the UMS
{code}
begin;
delete from ClientRICUsage where client_id = " client_id ";
delete from ClientRICUsageFree where client_id = " client_id ";
update Client set processed_ric_counts=0, processed_cash_count=0, processed_options_count=0, processed_futures_count=0 where id=" client_id ";
commit;
{code}\n")
  (insert "*** QA Plan\n")
  (insert "Log onto the UMS database with read access and run below sql:

select * from Client where id=" client_id ";

You should find processed_ric_counts and processed_cash_count are both 0

select count(1) from ClientRICUsage where client_id=" client_id ";
select count(1) from ClientRICUsageFree where client_id=" client_id ";

should return 0\n")
  (insert "*** Rollback Plan\n")
  (insert "In theory we can not really roll back when this customer start to use the system.

If it's really needed, roll back can be done based on the dump files generated in the deployment plan.\n"))

(defun bash-template()
  (interactive)
  (insert "
#!/bin/bash

E_BADARGS=85

if [ ! -n \"$1\" ]; then
    echo \"Usage: `basename $0` argument1 argument2 etc.\"
    exit $E_BADARGS
fi

cleanup()
# example cleanup function
{
    rm -f /tmp/tempfile
    return $?
}
 
control_c()
# run if user hits control-c
{
    echo -en \"\n*** Ouch! Exiting ***\n\"
    cleanup
    exit $?
}
 
# trap keyboard interrupt (control-c)
trap control_c SIGINT

loop_example()
{ 
    for i in $(seq 5); do
        echo \"Welcome $i times\"
    done
}

# main() loop
while true; do read x; done
"))

;;
;; Perl template
;;
;; # make a unique array
;; for (@array) { $foo{$_}++ };
;; @unique = (keys %foo);
;;


;;
;; Start with the bookmark screen
;;
(setq inhibit-splash-screen t)
(require 'bookmark)
(bookmark-bmenu-list)
(switch-to-buffer "*Bookmark List*")
(put 'narrow-to-region 'disabled nil)

(require 'desktop)
(desktop-save-mode 1)
(defun my-desktop-save ()
  (interactive)
  ;; Don't call desktop-save-in-desktop-dir, as it prints a message.
  (if (eq (desktop-owner) (emacs-pid))
      (desktop-save desktop-dirname)))
(add-hook 'auto-save-hook 'my-desktop-save)
