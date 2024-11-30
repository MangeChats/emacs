;; Ajouter une commande ilo pour restart db17/18 (ilo 3) => abandonné
;; Ajouter un ora-supervision-unlock et son menu oracle (Unlock supervison account, prompt MDP keypass) ?

(defun chg-veeeam-pwd ()
  (interactive)
  (cli "passwd veeam_backup\n"))

(setq helm-buffer-max-length nil) ; pour ne pas tronquer les buffers dans ²f ou C-x o
(setf dired-kill-when-opening-new-dired-buffer t)
(setq dired-dwim-target t) ; Copie d'un dired vers un autre
(setq auth-source-save-behavior 'ask)
(setq org-hide-emphasis-markers t)

(require 'real-auto-save)
(setq real-auto-save-interval 30) ; Sauvegarde auto toutes les 30 secondes avec real-auto-save-mode pour les shells

(defmacro voir (sexp)
  `(pp-emacs-lisp-code (macroexpand-1 ',sexp)))
(defmacro voir-min (sexp)
  "Version simplifiée de voir avec moins de dépendances"
  `(pp (macroexpand-1 ',sexp)))
(defmacro format-msg (prefixe fmt-str &rest rest)
  "A utiliser à la place de (format) pour afficher en plus qu'on a utilisé format-msg dans *messages*
   le prefix est une string qui permet de retrouver d'ou vient ce format. Serait mieux avec un defmacro/g!"
  (let ((m-fmt (concat prefixe fmt-str)))
  `(progn
     (message ,m-fmt ,@rest)
     (format ,fmt-str ,@rest))))
(defun revert-buffer-forced ()
  "Recharge le buffer avec le contenu actuel du fichier, assigné à F5"
  (interactive)
  (revert-buffer nil t))
(global-set-key (kbd "<f5>") 'revert-buffer-forced)

(define-prefix-command 'pde-map)
(global-set-key "²" pde-map)
(global-set-key "²²" 'other-window)
(global-set-key "²x" 'fermer-fichier)
(global-set-key "²s" 'save-buffer)
(global-set-key "²S" 'rec-find)
(global-set-key "²i" 'init-ssh)
(global-set-key "²q" 'save-buffers-kill-terminal)
(global-set-key (kbd "² <down>") (lambda () (interactive) (popup-menu menu-rouen)))
; ² BACKSPACE pour effacer une fenêtre du shell
(global-set-key "²" 'efface-shell)

(global-set-key (kbd "²b") 'choisir-base)
(global-set-key (kbd "²B") 'choisir-alias)
(global-set-key (kbd "²&") 'choisir-serveur-sudo-shell)
;;(global-set-key (kbd "²f") 'helm-buffers-list)
(global-set-key (kbd "²f") 'helm-mini)
(global-set-key (kbd "²o") 'helm-oracle)
(global-set-key (kbd "²O") 'ora-sql-cmd)

(global-set-key "²." 'goto-dired)
(global-set-key (kbd "²e") 'ouvre-shell-from-dired)

(global-set-key (kbd "²0") 'delete-window)
(global-set-key (kbd "²1") 'delete-other-windows)
(global-set-key (kbd "²2") 'split-window-below)
(global-set-key (kbd "²3") 'split-window-right)

(global-set-key (kbd "²$") 'my-tramp-term)
(global-set-key "²à" (lambda () (interactive)
		       (eval-buffer)
		       (message "Buffer évalué...")))

(global-set-key (kbd "²P") 'paredit-mode)
(global-set-key (kbd "²é") 'chg-veeeam-pwd)

;;(global-set-key (kbd "² TAB") 'god-local-mode)
;;(global-set-key (kbd "C-² C-S-Â") 'god-local-mode) ; Sortie de god mode par ²²

;;---------------------------------------------------------------- struct pour Oracle
(setq bases-proxmox
      '(("ALLORP" "hdvdb126")
	("PACNIP" "hdvdb127")
	("MARCOWP" "hdvdb128")
	("ETERNITP" "hdvdb129")
	("ADSOMAEP" "hdvdb130")
	("POLICEP" "hdvdb131")
	("ODPTLPEP" "hdvdb132")
	("ATALP" "hdvdb133")
	("DELIBP" "hdvdb134")
	("VIPP" "hdvdb135")
	("CONCERTP" "hdvdb136")
	("CONCERTI" "hdvdb136-infocentre")
	("SONATEP" "hdvdb137")
	("GRANGLEP" "hdvdb138")
	("GRANGLEI" "hdvdb138-infocentre")
	("GASICP" "hdvdb139")
	("GASICI" "hdvdb139-infocentre")
	("SIECLEP" "hdvdb140")
	("BOP" "hdvdb141")
	("SMRHP" "hdvdb142")
	("SMGFP" "hdvdb143")
	("ALLORT" "hdvdb126-test")
	("PACNIT" "hdvdb127-test")
	("MARCOWT" "hdvdb128-test")
	("ETERNITT" "hdvdb129-test")
	("ADSOMAET" "hdvdb130-test")
	("POLICET" "hdvdb131-test")
	("ODPTLPET" "hdvdb132-test")
	("ATALT" "hdvdb133-test")
	("DELIBT" "hdvdb134-test")
	("VIPT" "hdvdb135-test")
	("CONCERTT" "hdvdb136-test")
	("CONCERTF" "hdvdb136-form")
	("SONATET" "hdvdb137-test")
	("GRANGLET" "hdvdb138-test")
	("GRANGLEF" "hdvdb138-form")
	("GASICT" "hdvdb139-test")
	("SIECLET" "hdvdb140-test")
	("SMGFT" "hdvdb143-test")
	("test ansible GRANGLEF" "172.17.100.74")))

(setq bases-old
      '(("RHPROD"   "hdvdb123"       "/oracle/oradata/RHPROD" "ora12c")
	("RHINFO"   "hdvdb123-test"  "/oracle/oradata/RHINFO" "ora12c")
	("RHTEST"   "hdvdb123-test"  "/oracle/oradata/RHTEST" "ora12c")
	("SMRHP"    "hdvdb17"        "/oracle/oradata/RHTEST" "oracle11.2.0.4")
	("SDLP"     "hdvdb113"       "/oracle/11.2.0.4/db/SDLP"     "oracle11.2.0.4")
	("BOP"      "hdvdb120"       "/oradata/db/BOP"        "oracle")
	("CATRMAN"  "hdvdb122"       "/oradata/db/CATRMAN/"   "oracle")
	;;("GRANGLEP" "hdvdb120"       "/oradata/db/GRANGLEP"   "oracle")
	;;("GASICEP"   "hdvdb120"       "/oradata/db/GASICP"    "oracle")
	;;("GASICP"   "hdvdb120"       "/oradata/db/GASICP"     "oracle")
	;;("GASICI"   "hdvdb120"       "/oradata/db/GASICI"     "oracle")
	;;("GRANGLEI" "hdvdb120"       "/oradata/db/GRANGLEI"   "oracle")
	))

(setq bases-mysql
      '(("IKV"    "hdvdb117" "/var/lib/db/mysql/IKV" "root") ;; Appli sur HdvApp149 /srv/www/IKV/app
	("ONA"    "hdvdb117" "/var/lib/db/mysql/ONA" "root")
	("GRR"    "hdvwww17" "/var/lib/mysql/"       "root")
	("RNBI"   "hdvdb114" "/var/lib/mysql/rnbi"   "root")
	("GRRMDA" "hdvwww17" "/var/lib/mysql/"       "root")))

(setq bases-postgres
      '(("Maarch" "hdvdb121" "/var/lib/postgresql/12" "root")
	("API" "hdvapp163-test" "/var/lib/postgresql/14" "root")))

;; le champ 3 optionnel est la liste de bases dont est issue l'application, si absente c'est "bases-proxmox"
(setq alias-oracle
      '(("Astre Production - Ressources Humaines" "RHPROD" "bases-old")
	("Astre Test - Ressources Humaines" "RHTEST" "bases-old")
	("Astre Infocentre - Ressources Humaines" "RHINFO" "base-old")
	("Sedit Marianne Production - Gestion Financière" "SMGFP")
	("Sedit Marianne Production - Ressources Humaines" "SMRHP")
	("Adagio Production - Listes électorales" "ADSOMAEP")
	("Adagio Test - Listes électorales" "ADSOMAET")
	("Soprano Production - Animation élections" "ADSOMAEP")
	("Soprano Test - Animation élections" "ADSOMAET")
	("Maestro Production - Recencement citoyen" "ADSOMAEP")
	("Maestro Test - Recencement citoyen" "ADSOMAET")
	("Grand Angle Production- Gestion Financière" "GRANGLEP")
	("Grand Angle Test - Gestion Financière" "GRANGLET")
	("Grand Angle Infocentre - Gestion Financière" "GRANGLEI")
	("GASIC Production - Gestion Financière Sirest" "GASICP")
	("GASIC Test - Gestion Financière Sirest" "GASICT")
	("GASIC Infocentre - Gestion Financière Sirest" "GASICI")
	("VIP Production - Colis de Noël" "VIPP")
	("VIP Test - Colis de Noël" "VIPT")
	("Municipol Production - Police Municipale" "POLICEP")
	("Municipol Test - Police Municipale" "POLICET")
	("Colbert Production - Demandes interventions voirie" "ALLORP")
	("Colbert Test - Demandes interventions voirie" "ALLORT")
	("PACNI Production - Formalités administratives" "PACNIP")
	("PACNI Test - Formalités administratives" "PACNIT")
	("Marco Production - Rédaction Marchés Publiques" "MARCOP")
	("Marco Test - Rédaction Marchés Publiques" "MARCOT")
	("Eternité Production - Cimetières" "ETERNITP")
	("Eternité Test - Cimetières" "ETERNITTE")
	("Micronergie Production - ?" "ODPTLPEP")
	("Micronergie Test - ?" "ODPTLPET")
	("ATAL Production - Interventions, matériel, prêt de salles" "ATALP")
	("ATAL Test - Interventions, matériel, prêt de salles" "ATALT")
	("Delib Production - Gestion des délibérations" "DELIBP")
	("Delib Test - Gestion des délibérations" "DELIBT")
	("Concerto Production - Petite enfance, badgeages" "CONCERTP")
	("Concerto Test - Petite enfance, badgeages" "CONCERTT")
	("Concerto Infocentre - Petite enfance, badgeages" "CONCERTI")
	("Siecle Production - Actes d'état civil" "SIECLEP")
	("Siecle Test - Actes d'état civil" "SIECLET")
	("Business Object Production - Informatique décisionnelle" "BOP")
	("Sonate Production - Action Sociale" "SONATEP")
	("Sonate Test - Action Sociale" "SONATET")
	))

(setq alias-mysql
      '(("Indemnités Kilométriques Vélo Production" "IKV" "bases-mysql")
	("Open Net Admin Production - IPAM" "ONA" "bases-mysql")
	("Gestions Ressources CCAS Production - GRR" "GRR" "bases-mysql")
	("Gestions Ressources Maison des Ainés Production - GRR" "GRRMDA" "bases-mysql")
	("Site bibliothèques Production - RNBI" "RNBI" "bases-mysql")
	))
;;---------------------------------------------------------------- fonctions ssh
(defun efface-shell ()
  (interactive) 
  (kill-region (point-min) (point-max))
  (insert "\n")
  (comint-send-input))

(defun current-date ()
  (shell-command-to-string "echo -n $(date +%d-%m-%Y-%H:%M)"))

(defun current-dir ()
  "Retourne le répertoire de la fenêtre courante pour tramp ou en local"
  (let ((rep (if (derived-mode-p 'dired-mode)
	       dired-directory
	     default-directory)))
    (if (file-remote-p rep)
	(tramp-file-name-localname (tramp-dissect-file-name rep))
      rep)))

(defun current-srv ()
  "Retourne le serveur de la fenêtre courante pour tramp (et localhost sinon)"
  (let ((rep (if (derived-mode-p 'dired-mode)
	       dired-directory
	     default-directory)))
    (if (file-remote-p rep)
	(tramp-file-name-host (tramp-dissect-file-name rep))
      "localhost")))

(defun current-user ()
  "Retourne le user de la fenêtre courante pour tramp (et localhost sinon)"
  (let ((rep (if (derived-mode-p 'dired-mode)
	       dired-directory
	     default-directory)))
    (if (file-remote-p rep)
	(tramp-file-name-user (tramp-dissect-file-name rep))
      (distant-user))))

(defun goto-shell (&optional base)
  "Ouverture d'un shell sur le serveur courant"
  (interactive)
  (if (not base)
      (shell (format "*shell %s*" choosen-srv))
    (shell (format "*shell %s %s*" choosen-srv base))))

(defun change-cur-dir (full-path new-dir)
  "Remplace la partie répertoire deu chemin tramp complet fourni dans full-path
   par le new-dir"
  (replace-regexp-in-string "[^:]*$" new-dir full-path))

(defun goto-dired ()
  "Ouvre un dired sur le répertoire courant du serveur courant. En plus d'un dired std, stocke
   choosen-srv et chemin pour permettre à ²e de fonctionner"
  (interactive)
  (let ((srv (current-srv))
	(chemin (current-dir)))
    (message "goto-dired chemin:%s
default-directory:%s" chemin default-directory)
    (dired (change-cur-dir default-directory chemin))))

(defun  ouvre-shell-from-dired ()
  "Ouvre un shell sur le serveur et le répertoire courant d'un dired"
  (interactive)
  (unless (derived-mode-p 'dired-mode)
    (error "La fonction n'est disponible que depuis l'affichage d'un répertoire"))
  (ouvre-shell (current-srv) nil choosen-from-list (current-dir) (equal "root" (current-user))))

(defun ouvre-shell (srv &optional SID from-list chemin asroot)
  "Ouvre le buffer shell du serveur affiché (pour un dired, sinon c'est déjà lui).
   Si le shell n'est pas encore ouvert, l'ouvrir.
   Rechercher '*shell host' ou '*shell host sid' dans la liste des buffers (buffer-list)
   asroot t si ouverture as root"
  (interactive)
  (let* ((nom-buffer (format "*shell %s*" srv))
	 (found (cl-remove-if-not
		 (lambda (b)
		   (if SID
		       (string-match (format "*shell %s %s" srv SID) (buffer-name b))
		     (string-match (format "*shell %s" srv) (buffer-name b))))
		 (buffer-list)))
	 (rep (or chemin (current-dir))))
    (if found
	(progn
	  (switch-to-buffer  (car found)) ; le premier des found si trouvé
	  (comint-send-string (buffer-name) (format "cd %s\n" rep))) ; MAJ le répertoire à celui du dired
      ;; Pas trouvé on ouvre explicitement un shell
      (message "ouvre-shell !found => SRV=%s chemin=%s SID=%s asroot=%s" srv chemin SID asroot)
      (if asroot
	  (my-sudo-shell srv
			 (or chemin (base-default-dir choosen-base choosen-from-list))
			 (or SID choosen-base))
	(my-shell srv
		  (or chemin (base-default-dir choosen-base choosen-from-list))
		  (or SID choosen-base)))
      (setq-local choosen-srv srv)
      (if SID (setq-local choosen-base SID))
      (if from-list (setq-local choosen-from-list from-list))      
      (goto-char (point-max)))
    (REM (format "==> SRV=%s ORACLE_SID=%s DIR=%s ASROOT=%s à %s" srv (or choosen-base "VIDE") rep asroot (current-date) ))))

(defun ouvre-shell-root-direct (srv chemin)
  "Pour des machines n'ayant pas nos comptes admin (vieille ou appliances)"
  (interactive "sServeur: \nsChemin: ")
  (let ((default-directory
	  (format-msg "ouvre-shell-root-direct => "
		      "/scp:root@%s:%s"
		      srv
		      (or chemin (base-default-dir choosen-base choosen-from-list)))))
    (sleep-for 1.5)
    (shell (format-msg  "nom-shell => " "*shell %s*" srv))))

(defun copy-home ()
  "Copie sur votre home de hdvgen131
   Un partage windows comme S:/DSI/SOI/Infra-Prod est à prioriser (FAIT)"
  (interactive)
  (unless (derived-mode-p 'dired-mode)
    (error "La fonction n'est disponible que depuis l'affichage d'un répertoire"))
  (message "Fichier sélectionné: %s" (dired-get-file-for-visit))
  (message "Copie dans /home/%s de %s" (distant-user) (dired-get-file-for-visit))
  (copy-file (dired-get-file-for-visit) (format "/home/%s/" (distant-user))))

(defun tramp-to-scp (chemin)
  "Converti un chemin tramp d'une version ssh multihoop (avec |sudo:)
   ou le nouveau /sudo:root@srv en /scp:
   Sinon ne modifie rien"
  (cond ((string-match "^/ssh:" chemin)
	 (replace-regexp-in-string
	  "@.*@" "@"
	  (replace-regexp-in-string "^/ssh" "/scp" chemin)))
	((string-match "^/sudo:root" chemin)
	 (replace-regexp-in-string ".*@" (format "/scp:%s@" (distant-user))
				   chemin))
	(t chemin)))

(defvar AD-user nil "Utilisateur pour les partages bureautiques")
(defvar AD-pwd nil "Mot de passe pour les partages bureautiques")

(defun get-AD-user ()
  "Saisie un login / Mot de passe AD s'il n'est pas déjà en mémoire.
   Retourne seulement le user, les 2 sont gardés dans une variable globale"
  (when (null AD-user)
    (setq AD-user (read-string "Utilisateur pour l'accès au partage bureautique: " "pdedieu"))
    (setq AD-pwd (read-passwd "Mot de passe AD de l'utilisateur: ")))
  AD-user)

(defun monte-331 ()
  "Monte le répertoire nécessaire à hdvdb17. Pour test"
  (interactive)
  (let ((prev-buffer (buffer-name)))
    (switch-to-buffer  "*Messages*")
    (shell-command-to-string
	      (format "kinit %s <<<'%s'"
		      "adminBL" "69bgU6bW"))
    (if (< 0 (shell-command "mount -l | grep BLGF"))
	(message "Retour du mount: %s" (shell-command-to-string "mount /BLGF"))
      (message "Le montage est déjà fait => on ne refait pas"))
    (switch-to-buffer prev-buffer)))

(defun monte-bureautique ()
  "Monte le répertoire bureautique, et
   si back t retourne au buffer affiché
   sinon (défaut) l'affiche en dired"
  (interactive)
  (let ((prev-buffer (buffer-name)))
    (switch-to-buffer  "*Messages*")
    (shell-command-to-string
	      (format "kinit %s <<<'%s'"
		      (get-AD-user)
		      AD-pwd))
    (if (< 0 (shell-command "mount -l | grep DFS"))
	(message "Retour du mount: %s" (shell-command-to-string "mount /DFSService"))
      (message "Le montage est déjà fait => on ne refait pas"))
    (switch-to-buffer prev-buffer)))

(defun demonte-bureautique ()
  (interactive)
  (let ((prev-buffer (buffer-name)))
    (switch-to-buffer  "*Messages*")
    (message "Retour du umount: %s" (shell-command-to-string "umount /DFSService -v"))
    (switch-to-buffer prev-buffer)))

(defun my-scp (tramp-src local-dest &optional demonter)
  "Copie scriptée dans le buffer *shell* d'une copie scp OS"
  (let* ((split (tramp-dissect-file-name tramp-src))
	 (rep (tramp-file-name-localname split))
	 (srv (tramp-file-name-host split)))
    (switch-to-buffer "*Messages*")
    (shell)
    (let ((cmd (format "scp %s@%s:%s %s" (distant-user) srv rep local-dest)))
      (message "%s Début %s" (current-time-string) cmd)
      (let* ((ret (shell-command cmd))
	     (fin (current-time-string)))
	(message "%s Retour du scp: %s" fin ret)))
    (when demonter (demonte-bureautique))))

(defun copy-bureautique ()
  "Copie sur un partage windows comme S:/DSI/SOI/Infra-Prod
   le fait en SCP pas SSH pour éviter un long encodage encodage
   démonte le partage à la fin"
  (interactive)
  (unless (derived-mode-p 'dired-mode)
    (error "La fonction n'est disponible que depuis l'affichage d'un répertoire"))
  (let ((source (dired-get-file-for-visit))
	(destination "/DFSService/DSI/SOI/Infra-Prod/")
	(last-buffer (buffer-name)))
    (message "%s Début copie de: %s" (current-time-string) source)
    (monte-bureautique)
    (my-scp source (read-file-name "Répertoire de destination: " destination) t)  ; Mettre t pour démonter en sortie
    (switch-to-buffer last-buffer)))
(global-set-key "²c" 'copy-bureautique)

;; Ajustement du niveau de trace pour debug (3 est la valeur std)
;;(setq tramp-verbose 6)
(setq tramp-verbose 3)
(defun copy-other-srv ()
  "Copie sur un autre serveur via scp dans un shell
   Abandonné au profit de C dans dired après avoir ouvert un autre dired de destination"
  (interactive)
  (unless (derived-mode-p 'dired-mode)
    (error "La fonction n'est disponible que depuis l'affichage d'un répertoire"))
  (let* ((split (tramp-dissect-file-name (dired-get-file-for-visit)))
	 (srv-src (tramp-file-name-host split))
	 (rep-src (tramp-file-name-localname split))
	 (srv-dest (read-string "Serveur de destination: "))
	 (rep-dest (read-string "Répertoire de destination: "))
	 (prev-buffer (buffer-name)))
    (switch-to-buffer "*Messages*")
    (shell)
    (let ((cmd (format "scp %s:%s %s:%s"
		       srv-src rep-src
		       srv-dest rep-dest)))
      (message "%s Début %s" (current-time-string) cmd)
      (message "%s Retour du scp: %s" (current-time-string)
	       (shell-command cmd)))
    (switch-to-buffer prev-buffer)))
;;(global-set-key "²C" 'copy-other-srv)

(defun distant-user ()
  (cond  ((equal "pierre"  user-login-name) "adminpdedieu")
	 ((equal "pdedieu"  user-login-name) "adminpdedieu")
	 (t user-login-name)))

(defun dired-ftp (srv username rep)
  "Afficher un répertoire sur un serveur FTP"
  (interactive "sNom du serveur FTP à afficher: \nsNom d'utilisateur pour le site FTP: \nsRépertoire distant: ")
  (dired (format "/ftp:%s@%s:%s" username srv rep))
  )

(defun copy-ftp (srv username rep)
  "copy dired selected file to a FTP site"
  (interactive "sNom du serveur FTP de destination: \nsNom d'utilisateur pour le site FTP: \nsRépertoire de destination: ")
  (unless (derived-mode-p 'dired-mode)
    (error "La fonction n'est disponible que depuis l'affichage d'un répertoire"))
  (message "Fichier sélectionné: %s" (dired-get-file-for-visit))
  (copy-file (dired-get-file-for-visit) (format "/ftp:%s@%s:%s" username srv rep))
  (message "Copié vers ftp://%s@%s:%s" username srv rep)
  )

(setq smtpmail-default-smtp-server "mail.rouen.fr"
      smtpmail-local-domain "rouen.fr"
      send-mail-function 'smtpmail-send-it
      message-send-mail-function 'smtpmail-send-it
      user-full-name (format "%s sur Ansible" (distant-user))
      user-mail-address "pdedieu@rouen.fr"
      smtpmail-debug-info t
      smtpmail-debug-verbose t
      )

(defun copy-attachment ()
  (interactive)
  (unless (derived-mode-p 'dired-mode)
    (error "La fonction n'est disponible que depuis l'affichage d'un répertoire"))
  (let* ((fichier (dired-get-file-for-visit))
	 (mail-dest (current-user-mail))
	 (nom-local (tramp-file-name-localname (tramp-dissect-file-name fichier)))
	 (nom-court (file-name-nondirectory nom-local)))
    (setq user-mail-adress mail-dest)
    (compose-mail mail-dest (format "Envoi par moi même de %s" nom-court))
    (mml-attach-file fichier)
    (message-send-and-exit)
    (message "Envoi mail à %s de %s" mail-dest nom-court)))

(defun get-ip-address (&optional dev)
  "Get the IP-address for device DEV (default: eth0) of the current machine."
  (let ((dev (if dev dev "eth0"))) 
    (format-network-address (car (network-interface-info dev)) t)))

(defun web-dir-start (&optional port)
  "Lance le webserver emacs pour publier le répertoire courant sur le port (sinon 8000)"
  (interactive)
  (require 'simple-httpd)
  (setq httpd-listings t)
  (setq httpd-host (get-ip-address))
  (setq httpd-port (if port port 8000))
  (setq httpd-root (cur-dir))
  (message "=> Début de la publication web de %s (list=%s) sur http://%s:%s/"
	   httpd-root httpd-listings httpd-host httpd-port)
  (httpd-start))
(global-set-key "²w" 'web-dir-start)

(defun web-dir-stop ()
  (interactive)
  (message "=> Fin de publication web de %s" httpd-root)
  (httpd-stop))
(global-set-key "²W" 'web-dir-stop)

(defun fermer-fichier ()
  "Fermer le fichier ou la session SSH distante
   pour un shell, ignorer le modified
   et fermet le process du shell"
  (interactive)
  (let ((my-process (get-buffer-process (buffer-name))))
    (when my-process
      (delete-process my-process)
      (set-buffer-modified-p nil))
    (kill-current-buffer)))

;;---------------------------------------------------------------- fonctions Oracle

(defun REM (str)
  (insert "\n#==================================================================================================\n")
  (insert (format"#            %s" str))
  (comint-send-input))

(defun cli(cmd &optional buffer)
  (comint-send-string (if buffer buffer (buffer-name)) (format "%s\n" cmd)))

(defun init-ssh (srv)
  "A utiliser quand le serveur n'a pas encore été joint par SSH et qu'on doit enregistrer sa clef.
   Noter qu'on peut utiliser C-g + C-c pour aboandonner la connexion SSH
   dès qu'on a accepté la nouvelle clef par yes"
  (interactive "sNom du serveur: ")
  ;;(kill-buffer "*tramp.*")
  (switch-to-buffer "*Messages*")
  (shell)
  (require 'tramp)
  (require 'tramp-cmds)
  (tramp-cleanup-all-connections)
  (cli (format "ssh %s" srv) "*shell*"))

(defun ora-bash-cmd (cmd &optional comment)
  "Passer en shell d'une base de données avant !!
   Command SQL à passer sur la base Oracle courante
   Affiche le commentaire si existe"
  (interactive "sCommande à lancer en user Oracle: ")
  (unless (string-match "*shell [a-zA-Z0-9\\-]+ " (buffer-name))
    (error "Il faut être dans un shell de base oracle pour lancer cette commande..."))
  (and comment (REM comment))
  (let ((SID choosen-base)
	(liste choosen-from-list))
    (cli (format "su - %s" current-base-user))
    (cli "export PS1=\"\\$(whoami)@$(hostname) \\$(pwd) \\\\$ \"")
    (cli (format "export ORACLE_SID=%s" choosen-base))
    (cli cmd)
    (cli "exit")))

(defun echappe-%-and-lf (cmd)
  "échappe les % de la commande en les doublant pour ne pas interférer avec les token d'un format,
   supprime les LF et les espaces multiples consécutifs"
  (replace-regexp-in-string "\n" " "
			    (replace-regexp-in-string "%" "%%"
						      (replace-regexp-in-string " +" " " cmd))))


(defun ora-sql-cmd (cmd &optional comment pause)
  "Passer en shell d'une base de données avant !!
   Command SQL à passer sur la base Oracle courante
   Affiche dans le shell le commentaire si existe.
   Si pause, attends une frappe sur entrée avant de continuer.
   Si cmd vide, on reste dans le prompt SQL"
  (interactive "sCommande SQLplus: ")
  (let ((info (format "SQLplus sur %s avec SID:%s user:%s de %s"
		      choosen-srv choosen-base current-base-user (echappe-%-and-lf cmd))))
    (unless (string-match "*shell [a-zA-Z0-9\\-]+ " (buffer-name))
      (error "Il faut être dans un shell de base oracle pour lancer cette commande..."))
    (and comment (REM comment))
    (REM info)
    (let ((SID choosen-base)
	  (liste choosen-from-list))
      (if pause
	  (read-string (format "%s  =>Entrée pour le faire..." info))
	(sleep-for 0.5)
	(message info))
      (cli (format "su - %s" current-base-user))
      (cli "export PS1=\"\\$(whoami)@$(hostname) \\$(pwd) \\\\$ \"")
      (cli (format "export ORACLE_SID=%s" SID))
      (cli "sqlplus /nolog")
      (cli "connect / as sysdba")
      (unless (string= cmd "")
	(cli cmd)
	(sleep-for 0.5)
	(cli "exit")
	(sleep-for 0.5)
	(cli "exit"))
      )))

(defun ora-startup () (interactive)
  (ora-sql-cmd "startup"))
(defun ora-startup-mount () (interactive)
       (ora-sql-cmd "startup mount"))
(defun ora-startup-nomount () (interactive)
       (ora-sql-cmd "startup nomount"))
(defun ora-shut-imm () (interactive)
       (ora-sql-cmd "shutdown immediate"))
(defun ora-shut-abort () (interactive)
       (ora-sql-cmd "shutdown abort"))
(defun ora-status () (interactive)
  ;;(unless (string-match "*shell [a-zA-Z0-9\\-]+ " (buffer-name))
  ;;  (error "Il faut être dans un shell de base oracle pour lancer cette commande..."))
  (let ((SID (or choosen-base
		 (read-string "SID de la base dont vous voulez l'état: "))))
    (REM (format "Etat des listeners admin/production et de la base Oracle pour le serveur %s SID=%s\n" choosen-srv SID))
    (ora-bash-cmd (format "lsnrctl status %sadm" choosen-base))
    (sleep-for 0.5)
    (ora-bash-cmd (format "lsnrctl status %s" choosen-base))
    (sleep-for 0.5)
    (ora-sql-cmd "SELECT INSTANCE_NAME, STATUS, DATABASE_STATUS FROM V$INSTANCE;")))
(defun ora-start-listener ()
  "Passer en shell d'une base de données avant !!
   Démarre le listener de la base Oracle courante"
  (interactive)
  (ora-bash-cmd (format "lsnrctl start %s" choosen-base)))
(defun ora-stop-listener ()
  "Passer en shell d'une base de données avant !!
   Arrête le listener de la base Oracle courante"
  (interactive)
  (ora-bash-cmd (format "lsnrctl stop %s" choosen-base)))
(defun ora-view-alert ()
  "Passer en shell d'une base de données avant !!
   Affiche les traces d'alerte de la base Oracle courante"
  (interactive)
  (let ((prelude (cond ((equal choosen-base "GASICP") "SET HOMEPATH diag/rdbms/gasicp/GASICP;")
		       ((equal choosen-base "ADSOMAEP") "SET HOMEPATH diag/rdbms/adsomaep/ADSOMAEP;")
		       ((equal choosen-base "POLICET") "SET HOMEPATH diag/rdbms/policet/POLICET;")
		       ((equal choosen-base "RHPROD") "SET HOMEPATH diag/rdbms/rhprod/RHPROD;")
		       ((equal choosen-base "RHTEST") "SET HOMEPATH diag/rdbms/rhtest/RHTEST;")
		       ((equal choosen-base "SMGFP") "SET HOMEPATH diag/rdbms/smgfp/SMGFP;")
		       (t ""))))
    (ora-bash-cmd (format "adrci exec=\"%sSHOW ALERT -TAIL %s\""
			  prelude
			  (read-number "Nombre de lignes à afficher: " 10000))
		  (format "Affichage des dernières alertes oracle pour %s" choosen-base))))
(defun ora-show-connexions ()
  "Liste les connexions en cours sur la base actuelle"
  (interactive)
  (unless (string-match "*shell [a-zA-Z0-9\\-]+ " (buffer-name))
      (error "Il faut être dans un shell de base oracle pour lancer cette commande..."))
  (ora-bash-cmd "ps -ef | grep LOC[A]L" (format "Connexions sur la base %s" choosen-base)))
(defun ora-pga-size () (interactive)
  (ora-sql-cmd "select name.name,sum(stat.value)/1024/1024 PGA_MB
    from v$statname name,
         v$sesstat stat
    where name.statistic#=stat.statistic#
      and name.name like '%pga%'
    group by name.name;"
	       "Taille de la PGA"))

(defun ora-status-archivelogs ()
  "C'est une méthode, mais on peut aussi faire ps -ef | grep arc"
  (interactive)
  (ora-sql-cmd "archive log list;"))
(defun ora-set-archivelogs ()
  (interactive)
  (ora-sql-cmd "shutdown immediate" nil t)
  (ora-sql-cmd "startup mount" nil t)  
  (ora-sql-cmd "alter database archivelog;" nil t)
  (ora-sql-cmd "alter database open;" nil t)
  (ora-sql-cmd "archive log list;"))
(defun ora-stop-archivelogs ()
  (interactive)
  (ora-sql-cmd "shutdown immediate" nil t)
  (ora-sql-cmd "startup mount" nil t)  
  (ora-sql-cmd "alter database noarchivelog;" nil t)
  (ora-sql-cmd "alter database open;"))

(defun ora-end-backup ()
  (interactive)
  (ora-sql-cmd "alter database end backup;")
  (ora-sql-cmd "alter database open;"))

(defun ora-rman-register ()
  "Non DEBUGgué"
  (interactive)
  (let ((cmd (format "rman <<FIN
connect CATALOG rmanu/%s@CATRMAN
connect target /
register database;
FIN"
		     (read-string "mot de passe rmanu : "))))
    (REM (format "rman register pour la base %s sur %s :\n%s" choosen-base choosen-srv cmd))
    (ora-bash-cmd cmd "Register database")))

(defun ora-voir-archivelogs ()
  (interactive)
  (REM (format "Nom et taille Archivelogs pour la base %s sur %s" choosen-base choosen-srv))
  (ora-sql-cmd "SELECT trunc(first_time) JOURS, sum((blocks+1)*block_size)/1024/1024/1024 TAILLE_GO, count(*) NBR_FICHIERS  
                FROM gv$archived_log   
                GROUP BY  trunc(first_time)  
                ORDER BY trunc(first_time) DESC ;"))

(defun ora-occup-fra ()
  ;;  SELECT SPACE_USED/1024/1024/1024 "SPACE_USED(GB)" ,SPACE_LIMIT/1024/1024/1024 "SPACE_LIMIT(GB)" FROM  v$recovery_file_dest;
  (interactive)
  (REM (format "Occupation FRA pour la base %s sur %s" choosen-base choosen-srv))
  (ora-sql-cmd "SELECT SPACE_USED/1024/1024/1024 \"SPACE_USED(GB)\" ,SPACE_LIMIT/1024/1024/1024 \"SPACE_LIMIT(GB)\" FROM  v$recovery_file_dest;"))

(defun ora-contenu-fra ()
  ;;  SELECT file_type, space_used*percent_space_used/100/1024/1024 used,space_reclaimable*percent_space_reclaimable/100/1024/1024 reclaimable FROM v$recovery_file_dest, v$flash_recovery_area_usage;
  (interactive)
  (REM (format "Contenu de la FRA pour la base %s sur %s" choosen-base choosen-srv))
  (ora-sql-cmd "SELECT file_type, space_used*percent_space_used/100/1024/1024 used,
                space_reclaimable*percent_space_reclaimable/100/1024/1024 reclaimable
                FROM v$recovery_file_dest, v$flash_recovery_area_usage;"))

(defun ora-vide-fra ()
  "Si la base est bien dans le catalogue RMAN"
  (interactive)
  (let ((cmd (format "echo 'DELETE NOPROMPT ARCHIVELOG ALL;' | rman target / CATALOG rmanu/%s@CATRMAN"
		     (read-string "mot de passe rmanu : "))))
    (REM (format "Vidage FRA pour la base %s sur %s" choosen-base choosen-srv))
    (ora-bash-cmd cmd "Vidage via rman avec CATRMAN")))

(defun ora-vide-fra-test ()
  "Si la base n'est pas dans le catalogue RMAN (base test temp en Archivelog) => BUGGY ??"
  ;;  echo 'DELETE NOPROMPT ARCHIVELOG ALL;' | rman target /
  (interactive)
  (let ((cmd "echo 'DELETE NOPROMPT ARCHIVELOG ALL;' | rman target /"))
    (REM (format "Vidage FRA pour la base %s sur %s" choosen-base choosen-srv))
    (ora-bash-cmd cmd "Vidage via rman sans CATRMAN")))

(defun ora-rman-full ()
  "Sauvegarde RMAN Full suite à une relance de la base sur plantage"
  (interactive)
  (let ((cmd (format "/oracle/scripts/FullHotRmanBackupOracle.ksh %s"
		     (or choosen-base
			 (read-string "SID de la base pour la RMAN Full: ")))))
    (ora-bash-cmd cmd "Sauvegarde RMAN Full")))

(defun ora-dump ()
  "Sauvegarde d'un dump compressé de la base (pour le standard des VM Proxmox)"
  (interactive)
  (let* ((sid (or choosen-base
		  (read-string "SID de la base pour un dump compressé: ")))
	 (init-env (format "ORACLE_SID=%s;
FICDMP=/oradata/db/%s/export/%s.dmp;
FICLOG=/oradata/db/%s/export/%s.log;
FICTRC=/oradata/db/%s/export/%s.trc;
ORABIN=/oracle/product/19c/bin;
" sid sid sid sid sid sid sid))
	 (cmd-dump (format "%s /oracle/scripts/expdp-sys" init-env))
	 (cmd-compress (format "%s tar -cvzf $FICDMP.tar.gz $FICDMP; rm $FICDMP" init-env)))
    (ora-bash-cmd cmd-dump
		  (format "Dump de %s - log dans /oradata/db/%s/export/%s.log"
			  sid sid sid))
    (ora-bash-cmd cmd-compress "Compression du dump")))

(defun ora-sysrole-users ()
  "Affiches les users qui on un rôle comme sysdba, sysoper, sysasm, sysbackup, sysdg, syskm"
  (interactive)
  (let ((cmd "SELECT username,sysdba,sysoper,sysasm,sysbackup,sysdg,syskm FROM v$pwfile_users;"))
    (REM "Affichage des comptes avec des rôles sys")
    (ora-sql-cmd cmd)))

(defun ora-long-sql ()
  "Ajouter des champs de v$sql parmis sql_text, sql_fulltext, sql_id, last_load_time"
  (interactive)
  (REM "Affichage des requêtes les plus longues")
  ;; SET wrap off;
  ;; COLUMN sql_text format a700;
  (ora-sql-cmd "
SPOOL /tmp/sql-longues.txt
SET pagesize 0;
SET tab off;
SET trimspool on
SET long 32000
SET trimout on
SET colsep ' | ';
SET linesize 32000;
SELECT elapsed_time/1000000 seconds, v$sql.last_load_time, v$sql.sql_fulltext
From v$sql
ORDER BY elapsed_time DESC
FETCH FIRST 80 ROWS ONLY;
SPOOL OFF"))

(defun ora-veeam-transport-clr ()
  (interactive)
  (cli "ps -e | grep veeamagent")
  (read-string "Pas de process running ? Attente d'un return pour un stop veeamtransport ... ")
  (cli "service veeamtransport stop")
  (read-string "Attente d'un return pour uninstall veeamtransport ... ")
  (cli "/opt/veeam/transport/veeamtransport -u")
  (read-string "Attente d'un return pour rm -rf /opt/veeam/transport/ ... ")
  (cli "rm -rf /opt/veeam/transport/"))

(defun ora-force-archivelog-rotate ()
  (interactive)
  (ora-sql-cmd "ALTER SYSTEM SWITCH LOGFILE;" (format "Forcer une rotation d'archivelog pour %s" choosen-base)))

(defun veeam-delete-ufw-doubles ()
  (interactive)
  (cli "ufw --force enable")
  ;;(read-string "Attente d'un return pour suite ... ")
  (cli "ufw delete allow from 172.16.101.61 to any port 135,445,2500:3300,6167,10005 proto tcp comment 'veeam'")
  ;;(read-string "Attente d'un return pour suite ... ")
  (cli "ufw delete allow from 172.16.101.12 to any port 135,445,2500:3300,6167,10005 proto tcp comment 'veeam'")
  ;;(read-string "Attente d'un return pour suite ... ")
  (cli "ufw delete allow from 172.16.101.64 to any port 135,445,2500:3300,6167,10005 proto tcp comment 'veeam'")
  ;;(read-string "Attente d'un return pour suite ... ")
  (cli "ufw status"))

(setq cmd-oracle '(("Startup" ora-startup)
		   ("Startup mount" ora-startup-mount)
		   ("Startup nomount" ora-startup-nomount)
		   ("Etat base et listener" ora-status)
		   ("Shutdown immediate" ora-shut-imm)
		   ("Shutdown abort" ora-shut-abort)
		   ("Start listener" ora-start-listener)
		   ("Stop listener" ora-stop-listener)
		   ("voir Alertes" ora-view-alert)
		   ("voir Connexions" ora-show-connexions)
		   ("Status archivelog" ora-status-archivelogs)
		   ("Passage en archivelog" ora-set-archivelogs)
		   ("Arrêt des archivelog" ora-stop-archivelogs)
		   ("Forcer rotation archivelog" ora-force-archivelog-rotate)
		   ("Taille PGA" ora-pga-size)
		   ("RMAN register database" ora-rman-register)
		   ("Volume archivelogs" ora-voir-archivelogs)
		   ("Occupation FRA" ora-occup-fra)
		   ("Contenu FRA" ora-contenu-fra)
		   ("Vider la FRA (avec CATRMAN)" ora-vide-fra)
		   ("Vider la FRA (sans CATRMAN)" ora-vide-fra-test)
		   ("Faire une sauvegarde RMAN Full" ora-rman-full)
		   ("Faire un dump compressé de la base" ora-dump)
		   ("Users avec roles SYSxxx" ora-sysrole-users)
		   ("Requêtes SQL les plus longues" ora-long-sql)
		   ("Requête SQL manuelle" (lambda () (interactive)
					     (ora-sql-cmd (read-string "SQL cmd: "))))
		   ))

(setq src-cmd-oracle
      '((name . "Commandes Oracle")
	(candidates . cmd-oracle)
	(action . action-cmd)))

(defun helm-oracle ()
  (interactive)
  (helm :sources src-cmd-oracle :prompt "Commande Oracle: "))

(defun action-cmd (x)
  ;;(funcall (car x))
  (apply x))

;;------------------------------------------------------------------ fonctions proxmox
(setq cmd-proxmox '(("Shell HdvPve10" choisir-serveur-sudo-shell hdvpve10 "/etc/pve")
		    ("Shell HdvPve11" choisir-serveur-sudo-shell hdvpve11 "/etc/pve")
		    ("Shell PelPve10" choisir-serveur-sudo-shell pelpve10 "/etc/pve")
		    ("Shell PelPve11" choisir-serveur-sudo-shell pelpve11 "/etc/pve")
		    ("Shell PBS" choisir-serveur-sudo-shell hdvbkp16 "/root")
		    ("Appliquer les MAJ en attente" update-debian)
		    ("Lister les VM d'un PVE et leur PID" pve-qm-list)
		    ))

(setq cmd-esx '(("Shell HdvEsx112" ouvre-shell-root-direct hdvesx112 "/etc/")
		("Shell HdvEsx113" ouvre-shell-root-direct hdvesx113 "/etc/")
		("Shell HdvEsx114" ouvre-shell-root-direct hdvesx114 "/etc/")
		("Shell HdvEsx115" ouvre-shell-root-direct hdvesx115 "/etc/")
		("Shell HdvEsx116" ouvre-shell-root-direct hdvesx116 "/etc/")
		("Shell HdvEsx117" ouvre-shell-root-direct hdvesx117 "/etc/")
		("Shell PelEsx110" ouvre-shell-root-direct pelesx110 "/etc/")
		("Shell PelEsx111" ouvre-shell-root-direct pelesx111 "/etc/")
		("Shell PelEsx112" ouvre-shell-root-direct pelesx112 "/etc/")
		("Shell PelEsx113" ouvre-shell-root-direct pelesx113 "/etc/")
		;;("Appliquer les MAJ en attente" update-debian)
		;;("Lister les VM d'un PVE et leur PID" pve-qm-list)
		))

(defun compile-veeamsnap-new (veeam-version)
  "Compilation pour les OEL 8 de ProxMox ou "
  (interactive "sVersion du client Veeam à recompiler: ")
  (unless (string-match "*shell [a-zA-Z0-9\\-]+" (buffer-name))
    (error "Il faut être dans un shell de serveur Debian/Ubuntu ou OEL/ProxMox pour lancer cette commande..."))
  (cli (format "scl enable gcc-toolset-11 -- dkms install -m veeamsnap/%s --force" veeam-version)))

(defun compile-veeamsnap-old (veeam-version rpm-version)
  "Compilation pour les OEL < 8
   Passer dans veeam-version la version de client actuelle pour notre veeam (6.0.3.1221 ?)
   Passer dans rpm-version la version de veeamsnap telle que trouvée sur
   https://repository.veeam.com/backup/linux/agent/rpm/el/6/x86_64/
   Peut être du type 6.0.2.1168 ou 6.0.3.1221-1
   Passer en "
  (interactive "sVersion du client Veeam à recompiler: \nsVersion du rpm à utiliser: ")
  (unless (string-match "*shell [a-zA-Z0-9\\-]+" (buffer-name))
    (error "Il faut être dans un shell de serveur OEL ancien pour lancer cette commande..."))
  (cli (format "yum install veeamsnap-%s" rpm-version))
  (read-string "Appuyer sur Entrée pour continuer...")
  (cli (format "dkms add -m veeamsnap -v %s" veeam-version))
  (read-string "Appuyer sur Entrée pour continuer...")
  (cli (format "dkms build --force -m veeamsnap -v %s" veeam-version))
  (read-string "Appuyer sur Entrée pour continuer...")
  (cli (format "dkms install -m veeamsnap -v %s" veeam-version)))
(global-set-key "²v" 'compile-veeamsnap-old)

(defun reload-veeam-client ()
  "Décharger / recharger veeamsnap et redémarrer veeamservice (en cas de blocage) TODO !!"
  )

(defun update-debian ()
  (interactive)
  ;;Vérifier qu'on est sur le shell d'un PVE ou Ubuntu/Debian au moins
  (unless (string-match "*shell [a-zA-Z0-9\\-]+" (buffer-name))
    (error "Il faut être dans un shell de serveur Debian/Ubuntu ou ProxMox pour lancer cette commande..."))
  (cli "apt update")
  (cli "apt dist-upgrade"))

(defun pve-qm-list ()
  (interactive)
  (unless (string-match "*shell ...pve1[0-9]+" (buffer-name))
    (error "Il faut être dans un shell de serveur ProxMox pour lancer cette commande..."))
  (REM "Pour liberer un verrou: qm unlock VMID")
  (REM "Pour forcer l'arrêt d'une VM si le stop et le unlock échouent: kill -9 VMPID")
  (cli "qm list"))

(setq src-cmd-proxmox
      '((name . "Commandes Proxmox")
	(candidates . cmd-proxmox)
	(action . action-cmd)))

(defun helm-proxmox ()
  (interactive)
  (helm :sources src-cmd-proxmox :prompt "Commande ProxMox: "))

(setq src-cmd-esx
      '((name . "Commandes ESX")
	(candidates . cmd-esx)
	(action . action-cmd)))

(defun helm-esx ()
  (interactive)
  (helm :sources src-cmd-esx :prompt "Commande ESX: "))

(global-set-key (kbd "²p") 'helm-proxmox)

;;------------------------------------------------------------------ Ansible
(defvar ansible-buffer "*shell Ansible adminansible@hdvgen131*" "Nom du buffer pour le shell Ansible")
(defvar root-buffer "*shell root root@hdvgen131*" "Nom du buffer pour le shell root Ansible/Teicee")
(defvar local-buffer "*shell user hdvgen131*" "Nom du buffer pour le shell user Ansible")
(defvar last-adminansible-cmd nil "Pour un redo du dernier ansible-playbook")
(defvar last-root-cmd nil "Pour un redo du dernier root-playbook")
(defvar cache_pass nil "Mot de passe gardé en mémoire pour la session en cours (F6 pour l'insérer)")

(defun insert-pass (&optional read-it)
  "Insère le mot de passe en mémoire, commence par le demander s'il est vide ou si read-it est non null"
  (interactive)
  (when (or read-it (null cache_pass))
       (setq cache_pass (read-passwd "Votre mot de passe adminXXX: ")))
  (insert (format "%s\n" cache_pass)))
(global-set-key (kbd "<f6>") (lambda () (interactive) (insert-pass t)))
(global-set-key (kbd "<f7>") 'insert-pass)

(defun local-shell (&optional chemin)
  (interactive)
  (if (get-buffer local-buffer)
      (progn
	(switch-to-buffer  local-buffer)
	(cli (format "cd %s" chemin)))
    (let ((default-directory (or chemin "~")))
      (shell local-buffer)
      (comint-send-string root-buffer (format "cd %s\n" default-directory))))
    (goto-char (point-max)))

(defun root-shell (&optional chemin)
  (interactive)
  (if (get-buffer root-buffer)
      (switch-to-buffer  root-buffer)
    (let ((default-directory (or chemin "/root/ansible/")))
      (shell root-buffer)
      (comint-send-string root-buffer (format "cd %s\n" default-directory))
      (comint-send-string root-buffer "sudo -E -s\n"))
    (goto-char (point-max))))

(defun ansible-shell (&optional chemin)
  "Version inspirée de root-shell qui se connecte en adminansible"
  (interactive)
  (if (get-buffer ansible-buffer)
      (progn
	(switch-to-buffer  ansible-buffer)
	(when chemin (cli (format "cd %s" chemin))))
    (let ((default-directory (or chemin "/etc/ansible/")))
      (shell ansible-buffer)
      (comint-send-string ansible-buffer "sudo -i\n")
      (read-string "Appuyer sur Entrée pour continuer (passage en adminansible)...")
      (comint-send-string ansible-buffer "su adminansible\n")
      (comint-send-string ansible-buffer (format "cd %s\n" chemin))
      (goto-char (point-max)))))

(defun current-date ()
  (shell-command-to-string "echo -n $(date +%d-%m-%Y-%H:%M)"))

(defun get-limit-srv ()
  "Retourne un paramètre de limitation à un seul serveur du playbook
  ou rien si l'utilisateur n'en fourni pas"
  (let ((srv (read-string "Restreindre à un seul serveur (vide si pas nécessaire): ")))
    (if (> (length srv) 0)
	(format " -l %s.intranet.rouen.fr" srv)
      "")))

(defun ansible-run ()
  "Lancement d'un playbook sur tout l'inventaire Rouen"
  (interactive)
  (ansible-shell "/etc/ansible")
  (efface-shell)
  ;;(unless (equal (buffer-name) "*shell Ansible adminansible@hdvgen131*")
  (unless (equal (buffer-name) ansible-buffer)
    (error "Commande à lancer depuis le shell ansible mais on est dans %s" (buffer-name)))
  (let ((log-file (format "/tmp/ansible-run-%s.log" (current-date)))
	(cmd (read-string "Commande ansible-playbook (en adminansible): "
		    (format "ansible-playbook -i inventory/ %s%s"
			    (read-file-name "Choix du playbook: " "/etc/ansible/playbooks/" )
			    (get-limit-srv)))))
    (setq last-adminansible-cmd cmd)
    (write-file log-file)
    (REM (format "%s" cmd))
    (cli cmd)
    (real-auto-save-mode 1)))

(defun ansible-run-teicee-migration ()
  "Lancement d'un playbook de migration issu de Teicee"
  (interactive)
  (root-shell "/root/ansible")
  (efface-shell)
  (unless (equal (buffer-name) root-buffer)
    (error "Commande à lancer depuis le shell ansible"))
  (let ((log-file (format "/tmp/ansible-run-teicee-%s.log" (current-date)))
	(cmd (read-string "Commande ansible-playbook (en root): "
			  (format "ansible-playbook -D -i %s %s --ask-vault-pass "
				  (read-file-name "Choix de la base à migrer: " "/root/ansible/migration-bases-oracle/host-")
				  (read-file-name "Choix du playbook: " "/root/ansible/migration-bases-oracle/playbook-" )))))
    (REM (format "Trace dans %s pour\n%s" log-file cmd))
    (write-file log-file)
    (cli cmd)
    (real-auto-save-mode 1)))

(defun ansible-run-redo ()
  "Relancement du dernier playbook lancé sur tout l'inventaire Rouen"
  (interactive)
  (ansible-shell "/etc/ansible")
  (efface-shell)
  (unless (equal (buffer-name) "*shell Ansible adminansible@hdvgen131*")
    (error "Commande à lancer depuis le shell ansible mais on est dans %s" (buffer-name)))
  (unless last-adminansible-cmd
    (error "Pas de commande précédente..."))
  (let ((log-file (format "/tmp/ansible-run-%s.log" (current-date)))
	(cmd last-adminansible-cmd))
    (write-file log-file)
    (REM (format "%s" cmd))
    (cli cmd)
    (real-auto-save-mode 1)(real-auto-save-mode 1)
    (message "Pensez à sauver si vous voulez garder la trace complète (C-x w)")))

(defun ansible-run-teicee-redo ()
  "Lancement du dernier playbook de migration lancé issu de Teicee"
  (interactive)
  (root-shell "/root/ansible")
  (efface-shell)
  (unless (equal (buffer-name) root-buffer)
    (error "Commande à lancer depuis le shell root du serveur ansible"))
  (unless last-root-cmd
    (error "Pas de commande précédente..."))
  (let ((log-file (format "/tmp/ansible-run-teicee-%s.log" (current-date)))
	(cmd last-root-cmd))
    (write-file log-file)
    (REM (format "%s" cmd))
    (cli cmd)
    (real-auto-save-mode 1)
    (message "Pensez à sauver si vous voulez garder la trace complète (C-x w)")))

(defun dired-ansible-logs ()
  "Lister les fichiers de logs des lancements Ansible précédents"
  (interactive)
  (dired "/tmp/ansible-run*")
  (dired-sort-toggle-or-edit))

;;------------------------------------------------------------------

(defun ilo3-ssh-power ()
  "Utiliser les scripts shell de ilo-utils pour accès au power serveurs en ILO 3"
  (interactive)
  (let ((script (read-file-name "Script SSH à lancer: " "/home/adminpdedieu/ilo-utils-main/ilo-ssh-scripts/" nil t))
	(mdp (read-passwd "Mot de passe pour ILO Administrator: ")))
    (my-shell "ici" "/home/adminpdedieu/ilo-utils-main/ilo-ssh-scripts/")
    (cli (format "%s\n%s\n" script mdp))))

(defun current-user-mail ()
  "Confirme le mail rouen.fr de l'utilisateur courant pour un envoi de fichier"
  (format "%s@rouen.fr"
	  (read-string "Compte mail rouen.fr pour l'envoi: "
		       (substring (distant-user) 5))))

(defun my-dired (srv chemin)
  "Essai d'ouverture d'un répertoire distant avec adminXXX
   via tramp et yubikey
   si pas de chemin on le positionne suivant la base courante"
  (interactive "sServeur: \nsChemin du répertoire à afficher: ")
  (if (member srv '("hdvgen131" "ansible" "ici" "local" "localhost"))
      (local-dired)
    (find-file
     (format "/scp:%s@%s:%s"
	     (distant-user)
	     srv
	     chemin))))

(defun my-sudo-dired (srv chemin)
  "Essai d'ouverture d'un répertoire distant avec adminpdedieu
   via tramp, yubikey et sudo"
  (interactive "sServeur: \nsChemin du répertoire à afficher: ")
  (message "my-sudo-dired srv:%s chemin:%s user:%s"
	   srv chemin (distant-user))
  (message "=> /sudo:%s@%s:%s"
	   (distant-user) srv chemin)
  (find-file
   (format "/ssh:%s@%s|sudo:%s:%s"
	   (distant-user)
	   srv
	   srv
	   chemin)))

(defun my-shell (srv &optional chemin base)
  "Essai d'ouverture d'un shell SSH distant (ou local) avec adminXXXX
   via tramp, yubikey"
  (interactive "sServeur: \nsChemin du répertoire courant: ")
  (if (member srv '("hdvgen131" "ansible" "ici" "local" "localhost"))
      (local-shell chemin)
    (let ((default-directory
	    (format-msg "my-shell => "
			"/scp:%s@%s:%s"
			(distant-user)
			srv
			(or chemin (base-default-dir choosen-base choosen-from-list)))))
      (sleep-for 1.5)
      (if base
	  (shell (format-msg "nom-shell => " "*shell %s %s*" srv base))
	(shell (format-msg  "nom-shell => " "*shell %s*" srv))))))
(global-set-key "²m" 'my-shell)

(defun my-sudo-shell (srv chemin &optional base)
  "Essai d'ouverture d'un shell root SSH distant avec adminpdedieu
   via tramp, yubikey et sudo (srv est le nom court ou l'IP)"
  (interactive "sServeur: \nsChemin du répertoire courant: ")
  (let ((default-directory
	 (format "/ssh:%s@%s|sudo:%s:%s"
		 (distant-user)
		 srv
		 srv
		 (if (seq-contains srv ?.) ; si c'est un FQDN ou IP ignorer le base-default-dir
		     "/"
		   (or chemin (base-default-dir choosen-base choosen-from-list))))))
    (sleep-for 1)
    (if base
	(shell (format "*shell %s %s*" srv base))
      (shell (format "*shell %s*" srv)))))

(defun cur-dir ()
  "Retourne le répertoire courant"
  (if (derived-mode-p 'dired-mode)
      dired-directory
    default-directory))

(defun rec-find (pattern filtre-find option-grep)
  "Recherche récursive d'un pattern dans le répertoire courant d'un dired
   Propose e choix de paramètres prédéfinis"
  (interactive
   (list
    (read-string "Pattern à rechercher: ")
    (completing-read "Filtre optionnel pour find: "
		     '("-name *.yml"
		       "! -name '#*#'"
		       "-user oracle" "-group install"
		       "-path '*scripts*'"))
    (completing-read "Option(s) pour grep: "
		     '("-i"
		       "-C 4"))))
  (grep-find (format "find . ! -name '*.pyc' ! -name '*~' ! -path '*.git*' -type f %s -exec grep %s --color -nH --null -e '%s' \{\} 2>/dev/null +" filtre-find option-grep pattern))
  (delete-window))

(defun set-oracle-prompt (base)
  (comint-send-string (buffer-name) (format "export PS1=\"\\$(whoami)@$(hostname) (%s) \\$(pwd) \\\\$ \"\n" base)))

(defun member-keys (key alist)
  "nil si key n'est pas une des clefs de l'association list"
  (member key (mapcar #'car alist)))

(defun base-user (sid str-liste)
  "le user faisant tourner Oracle à partir du SID et de la liste (choosen-from-list) où on l'a choisie.
   pour les proxmox c'est 'oracle' pour les autres c'est le 4ième élément de la liste (0 based)"
  (if (equal str-liste "bases-proxmox")
      "oracle"
    (nth 3 (assoc sid (eval (intern str-liste))))))

(defun base-default-dir (sid str-liste)
  "le répertoire par défaut à ouvrir à partir du SID et de la liste (choosen-from-list) où on l'a choisie.
   pour les proxmox c'est '/oradata/sid/' pour les autres c'est le 3ième élément de la liste (0 based)"
  (if (null str-liste)
      "/"
    (if (equal str-liste "bases-proxmox")
	(format "/oradata/db/%s/export" sid)
      (nth 2 (assoc sid (eval (intern str-liste)))))))

;; TODO: il faut voir avec :around si on peut garder les valeurs des choosen-xx (avant et après le CD)
;; (advice-add 'cd
;; 	    :before
;; 	    (lambda (&rest r)
;; 	      (message "Pre-CD appelé avec %s" r))
;; 	    '((name . "pre-cd")))
;; (advice-add 'dired-find-file
;; 	    :before
;; 	    (lambda (&rest r)
;; 	      (message "Pre-dired-find-file appelé avec %s" r))
;; 	    '((name . "pre-dff")))
;; et pour l'enlever:
;;(advice-remove 'cd "pre-cd")
;;(advice-remove 'cd "pre-dff")
  
;;---------------------------------------------------------------- Helm
(defun keep-info-for-current-buffer (nom-base from-liste-name)
  "Place des variables locale au buffer pour les actions à suivre.
   Noter que la valeur est à stocker aussi a si on change de buffer..."
  ;;(message "Entrée du keep => base:%s  liste-name:%s" nom-base from-liste-name)
  (setq choosen-from-list from-liste-name)
  (setq choosen-srv (car (cdr (assoc nom-base (eval (intern from-liste-name))))))
  (setq choosen-base nom-base)
  (setq choosen-default-dir (base-default-dir choosen-base choosen-from-list))
  (setq current-base-user (base-user choosen-base choosen-from-list))
  ;; (message "keep-info => buffer=%s base=%s dir=%s user=%s srv=%s liste=%s"
  ;; 	   (buffer-name)
  ;; 	   choosen-base choosen-default-dir current-base-user choosen-srv choosen-from-list)
  )

(defmacro make-src-bases-4 (base-list-str src-title)
  "Création d'une source helm pour la alist base-list-str avec 4 actions"
  (let ((nom-fn-candidat (intern (format "candidats-%s" base-list-str)))
	(nom-src (intern (format "src-%s" base-list-str)))
	(nom-action-1 (intern (format "action-1-%s" base-list-str)))
	(nom-action-2 (intern (format "action-2-%s" base-list-str)))
	(nom-action-3 (intern (format "action-3-%s" base-list-str)))
	(nom-action-4 (intern (format "action-4-%s" base-list-str)))
	(base-list (intern base-list-str)))
    `(progn
       (defun ,nom-fn-candidat ()
	 (mapcar #'car ,base-list))
       (defun ,nom-action-1 (x)
	 "Ouverture d'un shell root sur le serveur de la base (x est le nom de la base de données)"
	 (message "%s => %s shell root sur srv=%s" ,src-title x (cadr (assoc x ,base-list)))
	 (keep-info-for-current-buffer x ,base-list-str)
	 (ouvre-shell choosen-srv choosen-base ,base-list-str (base-default-dir choosen-base choosen-from-list) t)
	 (keep-info-for-current-buffer x ,base-list-str)
	 (set-oracle-prompt x))
       (defun ,nom-action-2 (x)
	 "Ouverture d'un dired root sur le serveur"
	 (message "%s => %s dired root sur srv=%s" ,src-title x (cadr (assoc x ,base-list)))
	 (keep-info-for-current-buffer x ,base-list-str)
	 (my-sudo-dired (cadr (assoc x ,base-list))
			(format "/oradata/db/%s/export/" x)))
       (defun ,nom-action-3 (x)
	 "Ouverture du shell sur la base x"
	 (message "%s => %s shell sur srv=%s" ,src-title x (cadr (assoc x ,base-list)))
	 (keep-info-for-current-buffer x ,base-list-str)
	 (my-shell choosen-srv (base-default-dir choosen-base choosen-from-list) choosen-base)
	 (set-oracle-prompt x))
       (defun ,nom-action-4 (x)
	 "Ouverture d'un dired sur le serveur de la base x"
	 (message "%s => %s dired sur srv=%s" ,src-title x (cadr (assoc x ,base-list)))
	 (keep-info-for-current-buffer x ,base-list-str)
	 (my-dired (cadr (assoc x ,base-list))
		   (base-default-dir choosen-base choosen-from-list)))
       (setq ,nom-src '((name . ,src-title)
			(candidates . ,nom-fn-candidat)
			(action . (("Ouvre un shell root" . ,nom-action-1)
				   ("Ouvre un répertoire en root" . ,nom-action-2)
				   ("Ouvre un shell en adminXXX" . ,nom-action-3)
				   ("Ouvre un répertoire en adminXXX" . ,nom-action-4))))))))

;;(voir-min (make-src-bases-4 "bases-proxmox" "Sélection base Oracle sur ProxMox"))

(defun distant-user ()
  (cond  ((equal "pierre"  user-login-name) "adminpdedieu")
	 ((equal "pdedieu"  user-login-name) "adminpdedieu")
	 (t user-login-name)))

(defvar-local choosen-from-list nil "Nom de la liste dans laquelle la base a été choisie pour le buffer courant")
(defvar-local choosen-base nil "Nom de la base pour le buffer courant")
(defvar-local choosen-srv nil "Nom du server pour le buffer courant")
(defvar-local choosen-default-dir nil "répertoire par défaut pour la base choisie")
(defvar-local current-base-user nil "Nom du user qui fait tourner la base courante")

(defun choisir-serveur-sudo-shell (srv chemin &optional base)
  "Essai d'ouverture d'un shell root SSH distant avec adminXXXX
   via tramp, yubikey et sudo"
  (interactive "sServeur: \nsChemin du répertoire courant: ")
  (if (member srv '("hdvgen131" "ansible" "ici" "local" "localhost"))
      (root-shell chemin)
      (let ((default-directory
	      (format-msg "choisir-serveur-sudo-shell default-directory => "
			  "/ssh:%s@%s|sudo:%s:%s"
			  (distant-user)
			  srv
			  srv
			  chemin)))
	(sleep-for 1)
	(if base
	    (shell (format "*shell %s %s*" srv base))
	  (shell (format "*shell %s*" srv)))
	(cli "export PS1=\"\\$(whoami)@$(hostname) \\$(pwd) \\\\$ \"")
	(setq choosen-srv srv)
	(setq choosen-default-dir chemin)
	(setq choosen-base base))))

(defun choisir-base ()
  (interactive)
  (require 'tramp)
  (require 'tramp-cmds)
  (tramp-cleanup-all-connections)
  (make-src-bases-4 "bases-proxmox" "Bases Oracle sur ProxMox")
  (make-src-bases-4 "bases-old" "Base Oracle sur serveurs physiques")
  (make-src-bases-4 "bases-mysql" "Base MySQL")
  (make-src-bases-4 "bases-postgres" "Base PostgreSQL")
  (helm :sources '(src-bases-proxmox src-bases-old src-bases-mysql src-bases-postgres) :prompt "Quelques lettres du nom de la base: "))

(defmacro alias-to-base (alias from-list)
  "Nom de la base de donnée associée à l'alias dans from-list"
  `(cadr (assoc ,alias ,from-list)))

(defmacro alias-to-base-list-str (alias from-list)
  "Retourne le nom de la liste de base où se trouve celle dont l'alias est alias prise dans la liste from-list"
  `(or (nth 2 (assoc ,alias ,from-list))
       "bases-proxmox"))

(defmacro alias-to-srv (alias from-list)
  "Nom du serveur associé à l'alias dans from-list
(seulement pour les alias de bases proxmox dans un premier temps)"
  `(cadr (assoc (cadr (assoc ,alias ,from-list))
		(eval (intern (alias-to-base-list-str ,alias ,from-list))))))

(defmacro make-src-alias-4 (alias-list-str src-title)
  "Création d'une source helm pour la alist alias-list-str avec 4 actions (4 actions A ADAPTER !!)"
  (let ((nom-fn-candidat (intern (format "candidats-%s" alias-list-str)))
	(nom-src (intern (format "src-%s" alias-list-str)))
	(nom-action-1 (intern (format "action-1-%s" alias-list-str)))
	(nom-action-2 (intern (format "action-2-%s" alias-list-str)))
	(nom-action-3 (intern (format "action-3-%s" alias-list-str)))
	(nom-action-4 (intern (format "action-4-%s" alias-list-str)))
	(alias-list (intern alias-list-str)))
    `(progn
       (defun ,nom-fn-candidat ()
	 (mapcar #'car ,alias-list))
       (defun ,nom-action-1 (x)
	 "Ouverture d'un shell root sur le serveur de la base (x est le nom de l'alias / application de la base de données)"
	 (let ((nombase (alias-to-base x ,alias-list))
	       (nomsrv (alias-to-srv x ,alias-list))
	       (baseliststr (alias-to-base-list-str x ,alias-list)))
	   (message "%s => %s shell root sur srv=%s issu de %s" ,src-title nombase nomsrv baseliststr)
	   (keep-info-for-current-buffer nombase baseliststr)
	   (ouvre-shell choosen-srv choosen-base baseliststr (base-default-dir choosen-base choosen-from-list) t)
	   (keep-info-for-current-buffer nombase baseliststr)
	   (set-oracle-prompt nombase)))
       (defun ,nom-action-2 (x)
	 "Ouverture d'un dired root sur le serveur"
	 (let ((nombase (alias-to-base x ,alias-list))
	       (nomsrv (alias-to-srv x ,alias-list))
	       (baseliststr (alias-to-base-list-str x ,alias-list)))
	   (message "%s => %s dired root sur srv=%s" ,src-title nombase nomsrv)
	   (keep-info-for-current-buffer nombase baseliststr)
	   (my-sudo-dired nomsrv
			  (format "/oradata/db/%s/export/" nombase))))
       (defun ,nom-action-3 (x)
	 "Ouverture du shell sur la base x"
	 (let ((nombase (alias-to-base x ,alias-list))
	       (nomsrv (alias-to-srv x ,alias-list))
	       (baseliststr (alias-to-base-list-str x ,alias-list)))
	   (message "%s => %s shell sur srv=%s" ,src-title nombase nomsrv)
	   (keep-info-for-current-buffer nombase baseliststr)
	   (my-shell choosen-srv (base-default-dir choosen-base choosen-from-list) choosen-base)
	   (set-oracle-prompt nombase)))
       (defun ,nom-action-4 (x)
	 "Ouverture d'un dired sur le serveur de la base x"
	 (let ((nombase (alias-to-base x ,alias-list))
	       (nomsrv (alias-to-srv x ,alias-list))
	       (baseliststr (alias-to-base-list-str x ,alias-list)))
	   (message "%s => %s dired sur srv=%s" ,src-title nombase nomsrv)
	   (keep-info-for-current-buffer nombase baseliststr)
	   (my-dired nomsrv
		     (base-default-dir choosen-base choosen-from-list))))
       (setq ,nom-src '((name . ,src-title)
			      (candidates . ,nom-fn-candidat)
			      (action . (("Ouvre un shell root" . ,nom-action-1)
					 ("Ouvre un répertoire en root" . ,nom-action-2)
					 ("Ouvre un shell en adminXXX" . ,nom-action-3)
					 ("Ouvre un répertoire en adminXXX" . ,nom-action-4))))))))
(defun choisir-alias ()
  "Pour sélectionner une base de donnée à partir des infos sur l'application"
  (interactive)
  (require 'tramp)
  (require 'tramp-cmds)
  (tramp-cleanup-all-connections)
  (make-src-alias-4 "alias-oracle" "Applications avec des bases Oracle")
  (make-src-alias-4 "alias-mysql" "Applications avec des bases mysql")
  ;;(make-src-alias-4 "alias-postgres" "Applications avec des bases postgres")
  (helm :sources '(src-alias-oracle src-alias-mysql) :prompt "Quelques lettres du nom de l'application: "))

(defun monte-bureautique-show ()
  (interactive)
  (monte-bureautique)
  (sleep-for 2)
  (switch-to-buffer "*Messages*")
  (dired "/DFSService/DSI/SOI/Infra-Prod/"))

(defun show-process ()
  (interactive)
  (REM "Affichage des 30 process qui consomment le plus de temps")
  (cli "ps -e --sort=-cputime -o uid,state,stime,time,cmd | head -30")
  (cli "echo Aide colonnes: user-id state start-time cum-CPU-time Command")
  (sleep-for 1)
  (REM "Process en defunc")
  (cli "ps aux | egrep \"Z|def[u]nct\""))

(defun my-tramp-term ()
  "Ouvre un shell adminXXX permettant les commandes plein écran tel que
top, veeam, apt, ... sur le serveur courant
(voir pour ajouter sudo -i systématique ?)"
  (interactive)
  (tramp-term (list user-login-name (current-srv))))

;;;----------------------------------------------------------------------------------------- Un menu Rouen

(easy-menu-define menu-rouen nil ;global-map
  "Menu principal Rouen"
  '("ROUEN"
    ("Connexions SSH"
     ["Bases de données"  choisir-base :help "quelques lettres d'une base pour y ouvrir un shell"]
     ["Shell root serveur"  choisir-serveur-sudo-shell :visible isAdminVDR :help "Nom court du serveur et répertoire pour un shell root"]
     ["Shell serveur"  my-shell :keys "² m" :help "Choisissez un serveur et un répertoire de destination pour un shell en adminXXX"]
     ["ProxMox"  helm-proxmox :visible isAdminVDR ]
     ["ESX" heml-esx :visible isAdminVDR ]
     )
    ("Commandes"
     ["pour Oracle" helm-oracle :visible isAdminVDR ]
     ;;["Compiler veeamsnap (depuis shell d'une VM)" compile-veeamsnap :visible isAdminVDR]
     ["Afficher les process qui chargent" show-process :visible isAdminVDR]
     ["Réinitialiser veeamtransport (depuis shell d'une VM)" ora-veeam-transport-clr :visible isAdminVDR]
     ["ILO3 power" ilo3-ssh-power :visible isAdminVDR]
     ["Suggérer des commandes pour mysql ou autre..." nil]
     )
    ("Ansible"
     ["REDO dernier Run Ansible playbook sur inventory complet" ansible-run-redo :visible isAdminVDR]
     ["Run Ansible playbook sur inventory complet" ansible-run :visible isAdminVDR]
     ;;["REDO dernier Run Ansible playbook sur /root/ansible/migration-bases-oracle" ansible-run-teicee-redo :visible isAdminVDR]
     ["Run Ansible playbook sur /root/ansible/migration-bases-oracle" ansible-run-teicee-migration :visible isAdminVDR]
     ["Logs Ansible disponibles" dired-ansible-logs]
     ;;["Shell adminansible sur HdvGen131" ansible-shell :visible isAdminVDR]
     ;;["Shell root sur HdvGen131" root-shell :visible isAdminVDR]
     )
    ("Copies de fichiers"
     ["Copier le fichier sur S:\\DSI\\SOI" copy-bureautique]
     ["Monter le répertoire DFSService" monte-bureautique-show]
     ["Démonter le répertoire DFSService" demonte-bureautique]
     ["Envoi du fichier par mail" copy-attachment]
     ["Afficher un site FTP" dired-ftp]
     ["Envoyer le fichier par FTP" copy-ftp]
     ["Publier dossier sur http://172.17.100.63:8000/" 'web-dir-start]
     ["Arrêter de Publier sur http://172.17.100.63:8000/" 'web-dir-stop]
     )
    ("Fenêtres"
     ["choisir un répertoire ouvert"  choisir-dired]
     ["Séparation verticale"  fen-sep-vert]
     ["Séparation horizontale" fen-sep-horiz]
     ["Seule" fen-seule :keys (kdb "C-x 1")]
     ["Cacher" fen-cache])
    ("Signets"
     ["Liste des signets"  bookmark-bmenu-list]
     ["Ajouter signet pour l'emplacement courant" bookmark-set])
    ))

(defun isAdmin (id)
  (message "id:%s => %s" id (shell-command-to-string (format "id %s" id)))
  (string-match "adminVDR" (shell-command-to-string (format "id %s" id))))

;;---------------------------------------------------------------- accueil
(setq inhibit-splash-screen t)
(load-file "/etc/emacs/pde-mark-ring.el")
;;(load-file "pde-mark-ring.el")
;;(load-file "pde-mark-ring.el")
(setq make-backup-files nil)
(require 'bookmark)
(bookmark-bmenu-list)
(setq isAdminVDR ;TODO: récupérer l'appartenance au groupe sur gen131 pour adapter menus et defun
      (string-match "adminVDR" (shell-command-to-string "id")))
(switch-to-buffer "*Bookmark List*")
