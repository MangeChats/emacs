;; notmuch mail ----------------------------------------------
;; inspiré de https://ag91.github.io/blog/2024/09/19/enable-oauth-for-gmail-with-emacs-and-offlineimap/

;; setup the mail address and user name
(setq mail-user-agent 'message-user-agent)
(setq user-mail-address "MangeChats@gmail.com"
      user-full-name "Pierre DEDIEU")
;; smtp config
(setq smtpmail-smtp-server "smtp.gmail.com"
      message-send-mail-function 'message-smtpmail-send-it)
;; report problems with the smtp server
(setq smtpmail-debug-info t)
;; add Cc and Bcc headers to the message buffer
(setq message-default-mail-headers "Cc: \nBcc: \n")
;; postponed message is put in the following draft directory
(setq message-auto-save-directory "~/mail/draft")
(setq message-kill-buffer-on-exit t)
;; change the directory to store the sent mail
(setq message-directory "~/mail/")

(global-set-key (kbd "C-c m") 'notmuch-hello)
(global-set-key (kbd "C-c M") 'notmuch-exec-offlineimap)
(global-set-key (kbd "C-c d") 'notmuch-remove-deleted)

;;-----------------------------------------------------------------------------
(defun notmuch-exec-offlineimap-simplex ()
  "execute offlineimap pour syncho mails locaux et serveurs"
  (interactive)
  (start-process-shell-command "offlineimap"
                               "*offlineimap*"
                               "offlineimap -o")
  (sleep-for 15)
  (notmuch-refresh-all-buffers))

(defun notmuch-exec-offlineimap ()
    "execute offlineimap pour syncho mails locaux et serveurs"
    (interactive)
    (set-process-sentinel
     (start-process-shell-command "offlineimap"
                                  "*offlineimap*"
                                  "offlineimap -o")
     '(lambda (process event)
        (notmuch-refresh-all-buffers)
        (let ((w (get-buffer-window "*offlineimap*")))
          (when w
            (with-selected-window w (recenter (window-end)))))))
    (popwin:display-buffer "*offlineimap*"))

(require 'popwin)
(add-to-list 'popwin:special-display-config
             '("*offlineimap*" :dedicated t :position bottom :stick t
               :height 0.4 :noselect t))

(defun notmuch-remove-deleted ()
  "Efface les messages taggés deleted"
  (interactive)
  (shell-command "notmuch search --output=files tag:deleted | tr '\\n' '\\0' | xargs -0 -L 1 rm")
  (sleep-for 0.3)
  (notmuch-poll-and-refresh-this-buffer)
  )

(defun notmuch-tag-large-mails (taille)
  "Contourne l'absence de notion de taille dans notmuch la taille en paramètre"
  (interactive "nTaille max en Mega octets: ")
  (let ((cmd (format "for msg in $(
  for file in $(find ~/mail/ -type f -size +%sM);
    do
      grep -i ^Message-Id $file | sed -e \"s/^.*<\\(.*\\)>.*/\\1/\";
    done
    );
      do
        notmuch tag +large id:$msg;
      done"
		     taille)))
    ;;(message cmd)
    (shell-command cmd)
    (notmuch-search "tag:large")
    (delete-other-windows)
  ))

;;-----------------------------------------------------------------------------
;; Pour les envois:
(setq user-mail-address "MangeChats@gmail.com"
      user-full-name "Pierre DEDIEU")
(setq mail-user-agent 'message-user-agent)
(setq message-send-mail-function 'smtpmail-send-it
      smtpmail-stream-type 'starttls
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587)

(provide 'pde-mail)
