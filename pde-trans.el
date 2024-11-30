;;; pde-trans.el --- Utilisation de transient pour faciliter l'utilisation des commandes emacs
;; TODO: ajouter les commandes proxmox
;; TODO: un autre pour (buffer-menu-open) pour l'instant C-<F10>
;;-------------------------------------------------------- Utilitaires

(which-key-mode 1)
(winner-mode 1)
;;  Ajouter quelques raccourcis nécessaires en terminal car C-<left> et <right> ne fonctionnent pas ni C-^
(eval-after-load 'paredit
  (lambda ()
    (local-set-key (kbd "C-c ç") 'join-line)
    (local-set-key (kbd "C-c <left>") 'paredit-forward-barf-sexp)
    (local-set-key (kbd "C-c <right>") 'paredit-forward-slurp-sexp)))
;;  ². dans un shell pour afficher le répertoire courant dans un dired
(add-hook 'shell-mode-hook
  (lambda ()
    (local-set-key (kbd "².") 'dired)
    (local-set-key (kbd "²p") 'ora-sqlplus)))
;;  ². dans un dired pour ouvrir un shell dans ce répertoire
(add-hook 'dired-mode-hook
  (lambda ()
    (local-set-key (kbd "².") (lambda () (interactive)
				(open-ssh-console (or choosen-srv "localhost")
						  (or choosen-default-dir default-dir)
						  (or current-base-user user-login-name))))))

(defun fermer-buffer ()
  "Fermer le fichier ou la session SSH distante
   pour un shell, ignorer le modified
   et fermer le process du shell"
  (interactive)
  (let ((my-process (get-buffer-process (buffer-name))))
    (when my-process
      (delete-process my-process)
      (set-buffer-modified-p nil))
    (kill-current-buffer)))

(defun extraire (params)
  "Transforme la liste des paramètres de transient en association-list"
  (let* ((p (car params))
	 (tranche (if (stringp p)
		      p
		    (symbol-name p))))
    (cond
     ((null params) nil)
     ((string-match "\\(.*\\)=\\(.*\\)" tranche) (cons (read-paire tranche) (extraire (cdr params))))
     ((stringp tranche) (cons (cons "noname" tranche)
			      (extraire (cdr params)))))))

(defun read-paire (str)
  "Récupère les deux partie sélectionnées par le string-match dans un cons"
  (cons (match-string 1 str) (match-string 2 str)))

(defun format-param (k fmt-str default asso)  
  "Si la clef k a une valeur dans l'association list asso retourne cette valeur formatée selon fmt-str. Sinon default"
  (let ((v (cdr (assoc k asso #'string=))))
    (if v
	(format fmt-str v)
      default)))

(defun lire-date (&optional prompt)
  (interactive)
  (transient-read-date (or prompt "Date: ") nil nil))

(defun lire-repertoire (&optional prompt)
  (interactive)
  (setq default-directory
	(transient-read-existing-directory
	 (or prompt "Répertoire: ") nil nil)))

(defun lire-fichier (&optional prompt def)
  (interactive)
  (transient-read-existing-file
   (or prompt "Fichier: ") def nil))

(defvar le-mdp nil "Mot de passe gardé en mémoire")
(defun reset-mdp ()
  (interactive)
  (insert (setf le-mdp (read-passwd "Mot de passe à mémoriser: "))))
(defun mot-de-passe ()
  (interactive)
  (if le-mdp
      (insert le-mdp)
    (reset-mdp)))

(defun petit-eshell (&optional hauteur)
  "Ouvre une petite fenêtre eshell en bas de l'écran ou la cache si présente"
  (interactive)
  (let ((ebuf (get-buffer "*eshell*")))
    (if ebuf
	(progn
	  (delete-windows-on ebuf)
	  (kill-buffer ebuf))
      (progn
	(setq eshell-buffer-name "*eshell*")
	(split-window-below (- (or hauteur 5)))
	(other-window 1)
	(eshell)))))

(define-skeleton reveal-skel
  "En tête pour une présentation revealjs"
  "Titre de présentation : "
  ":METADONNEES:" \n
  "#+TITLE: " str \n
  "#+LANGUAGE: fr" \n
  ":END:" \n \n
  ":REVEALJS:" \n
  "#+REVEAL_ROOT: https://cdn.jsdelivr.net/npm/reveal.js" \n
  "#+REVEAL_VERSION: 4" \n
  "#+REVEAL_THEME: league" \n
  "#+REVEAL_TRANS: cube" \n
  "#+OPTIONS: toc:t num:t" \n
  ":END:" \n \n _ )
(define-skeleton diapo-skel
 "Insertion d'une diapo dans une présentation revealjs"
  "Titre de la diapo : "
  "* " str \n
  "#+BEGIN_NOTES" \n _ \n
  "#+END_NOTES" \n
  "#+ATTR_REVEAL: :frag (appear)" \n \n )
(global-set-key (kbd "C-*") 'diapo-skel)
(define-abbrev-table 'html-mode-abbrev-table '(("fht" "" html-skeleton) ("par" "<p></p>\n") ("gg" "J'y suis !" nil)))
(define-abbrev-table 'org-mode-abbrev-table '(("frg" "" org-skel) ("frv" "" reveal-skel)))

(defun pde-hide-columns ()
  "Pour faciliter l'utilisation de set-selective-display,
Cache les lignes commençant après la colonne courante,
ou montre tout si des lignes sont déjà cachées"
  (interactive)
  (if selective-display
      (set-selective-display nil)
    (set-selective-display (1+ (current-column)))))
(global-set-key (kbd "C-c $") 'pde-hide-columns)

(defun trouve-bases (srv liste)
  "Recherches les bases associéeau serveur srv dans la liste (ex bases-proxmox)"
  (mapcar (lambda (l) (car l))
	  (cl-remove-if-not (lambda (li)
			      (string= (cadr li) srv))
			    liste)))

(defun srv-to-bases (srv)
  "Affiche la/les bases de données associées à un serveur"
  (interactive "sNom du serveur dont on cherche les bases de données: ")
  (message "Bases de données sur %s: %s" srv
	   (or (trouve-bases srv bases-proxmox)
	       (trouve-bases srv bases-old)
	       (trouve-bases srv bases-mysql)
	       (trouve-bases srv bases-postgres)
	       "Aucune trouvée")))

;;-------------------------------------------------------- infos sur la Mairie pour helm
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
      '(("RHPROD"   "hdvdb123"       "/oracle" "ora12c") ; ou /oracle/oradata/RHPROD
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
	("Astre Infocentre - Ressources Humaines" "RHINFO" "bases-old")
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
	("Solfami Concerto Production - Petite enfance, badgeages" "CONCERTP")
	("Solfami Concerto Test - Petite enfance, badgeages" "CONCERTT")
	("Solfami Concerto Infocentre - Petite enfance, badgeages" "CONCERTI")
	("Siecle Production - Actes d'état civil" "SIECLEP")
	("Siecle Test - Actes d'état civil" "SIECLET")
	("Business Object Production - Informatique décisionnelle" "BOP")
	("Sonate Production - Action Sociale" "SONATEP")
	("Sonate Test - Action Sociale" "SONATET")
	))

(setq alias-old
      '(("Astre RH Production - Ressources Humaines" "RHPROD" "bases-old")
	("Astre RH Infocentre" "RHINFO" "bases-old")
	("Astre RH Test" "RHTEST" "bases-old")
	("Sedit Marianne RH Production - Ressources Humaines CCAS" "SMRHP" "bases-old")
	("Catalogue Rman Production - Base outil RMAN" "CATRMAN" "bases-old")
	))

(setq alias-mysql
      '(("Indemnités Kilométriques Vélo Production" "IKV" "bases-mysql")
	("Open Net Admin Production - IPAM" "ONA" "bases-mysql")
	("Gestions Ressources CCAS Production - GRR" "GRR" "bases-mysql")
	("Gestions Ressources Maison des Ainés Production - GRR" "GRRMDA" "bases-mysql")
	("Site bibliothèques Production - RNBI" "RNBI" "bases-mysql")
	))

;;-------------------------------------------------------- helm et applications
(defun choisir-alias ()
  "Pour sélectionner une base de donnée à partir des infos sur l'application"
  (interactive)
  (require 'tramp)
  (require 'tramp-cmds)
  (tramp-cleanup-all-connections)
  (make-src-alias-3 "alias-oracle" "Applications avec des bases Oracle")
  (make-src-alias-3 "alias-old" "Base Oracle hors ProxMox")
  (make-src-alias-3 "alias-mysql" "Applications avec des bases mysql")
  (helm :sources '(src-alias-oracle src-alias-old src-alias-mysql) :prompt "Quelques lettres du nom de l'application: "))

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

(defmacro make-src-alias-3 (alias-list-str src-title)
  "Création d'une source helm pour la alist alias-list-str avec 3 actions"
  (let ((nom-fn-candidat (intern (format "candidats-%s" alias-list-str)))
	(nom-src (intern (format "src-%s" alias-list-str)))
	(nom-action-1 (intern (format "action-1-%s" alias-list-str)))
	(nom-action-2 (intern (format "action-2-%s" alias-list-str)))
	(nom-action-3 (intern (format "action-3-%s" alias-list-str)))
	(alias-list (intern alias-list-str)))
    `(progn
       (defun ,nom-fn-candidat ()
	 (mapcar #'car ,alias-list))
       (defun ,nom-action-1 (x)
	 "Ouverture d'un shell sur le serveur de la base (x est le nom de l'alias / application de la base de données)"
	 (let ((nombase (alias-to-base x ,alias-list))
	       (nomsrv (alias-to-srv x ,alias-list))
	       (baseliststr (alias-to-base-list-str x ,alias-list)))
	   (message "%s => %s shell sur srv=%s issu de %s" ,src-title nombase nomsrv baseliststr)
	   (open-ssh-and-keep-info :shell nombase baseliststr)
	   (set-oracle-prompt nombase)))
       (defun ,nom-action-2 (x)
	 "Ouverture d'un dired sur le serveur"
	 (let ((nombase (alias-to-base x ,alias-list))
	       (nomsrv (alias-to-srv x ,alias-list))
	       (baseliststr (alias-to-base-list-str x ,alias-list)))
	   (message "%s => %s dired sur srv=%s" ,src-title nombase nomsrv)
	   (open-ssh-and-keep-info :dired nombase baseliststr)))
       (defun ,nom-action-3 (x)
	 "Ouverture d'un terminal sur le serveur"
	 (let ((nombase (alias-to-base x ,alias-list))
	       (nomsrv (alias-to-srv x ,alias-list))
	       (baseliststr (alias-to-base-list-str x ,alias-list)))
	   (message "%s => %s terminal sur srv=%s" ,src-title nombase nomsrv)
	   (open-ssh-and-keep-info :term nombase baseliststr)))
       (setq ,nom-src '((name . ,src-title)
			      (candidates . ,nom-fn-candidat)
			      (action . (("Ouvre un shell" . ,nom-action-1)
					 ("Ouvre un répertoire" . ,nom-action-2)
					 ("Ouvre un terminal" . ,nom-action-3))))))))

;;-------------------------------------------------------- helm et SSH
(defun choisir-base ()
  (interactive)
  (require 'tramp)
  (require 'tramp-cmds)
  (tramp-cleanup-all-connections)
  (make-src-bases-3 "bases-proxmox" "Bases Oracle sur ProxMox")
  (make-src-bases-3 "bases-old" "Base Oracle hors ProxMox")
  (make-src-bases-3 "bases-mysql" "Base MySQL")
  (make-src-bases-3 "bases-postgres" "Base PostgreSQL")
  (helm :sources '(src-bases-proxmox src-bases-old src-bases-mysql src-bases-postgres) :prompt "Quelques lettres du nom de la base: "))

(defvar-local choosen-from-list nil "Nom de la liste dans laquelle la base a été choisie pour le buffer courant")
(defvar-local choosen-base nil "Nom de la base pour le buffer courant")
(defvar-local choosen-srv nil "Nom du server pour le buffer courant")
(defvar-local choosen-default-dir nil "répertoire par défaut pour la base choisie")
(defvar-local current-base-user nil "Nom du user qui fait tourner la base courante")
(defvar-local in-sqlplus nil "Booleen, t si on est dans un prompt SQLPlus")

(defun open-ssh-and-keep-info (type nom-base from-liste-name)
  "Ouvre un buffer du type :shell :term ou :dired
   pour la base nom-base issue de la liste from-nom-liste
   et mets à jour des variables locales au buffer pour la base et ses valeurs par défaut"
  (let ((srv (car (cdr (assoc nom-base (eval (intern from-liste-name))))))
	(default-dir (base-default-dir nom-base from-liste-name))
	(base-user (base-user nom-base from-liste-name)))
    (message "open-ssh-and-keep-info base:%s from-list:%s type:%s def-dir:%s" nom-base from-liste-name type default-dir)
    (cond ((eq :shell type) (open-ssh-console srv default-dir nom-base))
	  ((eq :term type) (open-ssh-term srv))
	  ((eq :dired type) (open-ssh-directory srv default-dir nom-base))
	  (t (error "Le type %s n'est pas encore supporté par open-ssh-and-keep-info" type)))
    (setq choosen-from-list from-liste-name)
    (setq choosen-srv srv)
    (setq choosen-base nom-base)
    (setq choosen-default-dir default-dir)
    (setq current-base-user base-user)))

(defun base-user (sid str-liste)
  "le user faisant tourner Oracle à partir du SID et de la liste (choosen-from-list) où on l'a choisie.
   pour les proxmox c'est 'oracle' pour les autres c'est le 4ième élément de la liste (0 based)"
  (if (equal str-liste "bases-proxmox")
      "oracle"
    (nth 3 (assoc sid (eval (intern str-liste))))))

(defun base-default-dir (sid str-liste)
  "le répertoire par défaut à ouvrir à partir du SID et de la liste (choosen-from-list) où on l'a choisie.
   pour les proxmox c'est '/oradata/sid/' pour les autres c'est le 3ième élément de la liste (0 based)"
  (message "base-default-dir pour sid=%s list:%s" sid str-liste)
  (if (null str-liste)
      "/"
    (if (equal str-liste "bases-proxmox")
	(format "/oradata/db/%s/export" sid)
      (nth 2 (assoc sid (eval (intern str-liste)))))))

(defun set-oracle-prompt (base)
  (comint-send-string (buffer-name) (format "export PS1=\"\\$(whoami)@$(hostname) (%s) \\$(pwd) \\\\$ \"\n" base)))

(defmacro make-src-bases-3 (base-list-str src-title)
  "Création d'une source helm pour la alist base-list-str avec 3 actions"
  (let ((nom-fn-candidat (intern (format "candidats-%s" base-list-str)))
	(nom-src (intern (format "src-%s" base-list-str)))
	(nom-action-1 (intern (format "action-1-%s" base-list-str)))
	(nom-action-2 (intern (format "action-2-%s" base-list-str)))
	(nom-action-3 (intern (format "action-3-%s" base-list-str)))
	(base-list (intern base-list-str)))
    `(progn
       (defun ,nom-fn-candidat ()
	 (mapcar #'car ,base-list))
       (defun ,nom-action-1 (x)
	 "Ouverture d'un shell root sur le serveur de la base (x est le nom de la base de données)"
	 (message "%s => %s shell root sur srv=%s" ,src-title x (cadr (assoc x ,base-list)))
	 (open-ssh-and-keep-info :shell x ,base-list-str)
	 (set-oracle-prompt x))
       (defun ,nom-action-2 (x)
	 "Ouverture d'un dired sur le serveur"
	 (message "%s => %s dired root sur srv=%s" ,src-title x (cadr (assoc x ,base-list)))
	 (open-ssh-and-keep-info :dired x ,base-list-str))
       (defun ,nom-action-3 (x)
	 "Ouverture d'un terminal sur le serveur"
	 (message "%s => %s terminal sur srv=%s" ,src-title x (cadr (assoc x ,base-list)))
	 (open-ssh-and-keep-info :term x ,base-list-str))
       (setq ,nom-src '((name . ,src-title)
			(candidates . ,nom-fn-candidat)
			(action . (("Ouvre un shell" . ,nom-action-1)
				   ("Ouvre un répertoire" . ,nom-action-2)
				   ("Ouvre un terminal" . ,nom-action-3)
				   )))))))

;;-------------------------------------------------------- Commandes oracle
(setq cmd-oracle '(("Startup" ora-startup)
		   ("Startup mount" ora-startup-mount)
		   ("Startup nomount" ora-startup-nomount)
		   ("Etat base et listener" ora-status)
		   ("Shutdown immediate" ora-shut-imm)
		   ("Shutdown abort" ora-shut-abort)
		   ("Start listener" ora-start-listener)
		   ("Stop listener" ora-stop-listener)
		   ("ADRCI dernières alertes" ora-view-alert)
		   ("Afficher fichier de log des traces" ora-alert-log)
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
		   ("Pourcentage d'utilisation des tablespaces" ora-tablespace)
		   ("Vidage de l'AUDIT_TRAIL" ora-purge-audit-trail)
		   ("SQLPlus prompt (refaire pour sortir)" ora-sqlplus)
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

(defun REM (str)
  (insert "\n#==================================================================================================\n")
  (insert (format"#            %s" str))
  (comint-send-input))

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

(defun ora-sqlplus ()
  "Session interactive en sqlplus avec les bons préliminaires (TODO: toggle et retour au shell root)"
  (interactive)
  (unless (and (string-match "*shell hdvdb" (buffer-name))
	       choosen-base)
    (error "Il faut être dans un shell de base oracle pour lancer cette commande..."))
  (if in-sqlplus
      (progn (cli "exit")
	     (sleep-for 0.5)
	     (cli "exit")
	     (setf in-sqlplus nil))
    (progn (cli (format "su - %s" current-base-user))
	   (cli (format "export ORACLE_SID=%s" choosen-base))
	   (cli "sqlplus /nolog")
	   (setf in-sqlplus t)
	   (cli "connect / as sysdba"))))

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
  (ora-bash-cmd (format "lsnrctl start %s" choosen-base)))(defun ora-stop-listener ()
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
			  (read-number "Nombre de lignes à afficher: " 100))
		  (format "Affichage des dernières alertes oracle pour %s" choosen-base))))
(defun ora-alert-log ()
  (interactive)
  (ora-sql-cmd "SELECT value FROM v$diag_info WHERE name = 'Default Trace File';")
  (re-search-backward "^----")
  (next-line)
  (save-excursion
    (dired (format "/sudo:root@%s:%s*.log*"
		   choosen-srv
		   (file-name-directory (thing-at-point 'line))))))
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

; 
(defun ora-tablespace ()
  (interactive)
  (REM (format "Pourcentage utilisation Tablespaces pour la base %s sur %s" choosen-base choosen-srv))
  (ora-sql-cmd "select * From DBA_TABLESPACE_USAGE_METRICS;"))

(defun ora-purge-audit-trail ()
  (interactive)
  (REM (format "Vidage AUDIT_TRAIL pour la base %s sur %s" choosen-base choosen-srv))
  (ora-sql-cmd "BEGIN
DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(
AUDIT_TRAIL_TYPE => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
USE_LAST_ARCH_TIMESTAMP => FALSE,
CONTAINER => dbms_audit_mgmt.container_current);
END;
/ 
"))

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
  (let ((cmd (format (if (equal "RHPROD" choosen-base)
			 "/oracle/exploit/FullHotRmanBackupOracle.ksh %s"
			 "/oracle/scripts/FullHotRmanBackupOracle.ksh %s")
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

;;-------------------------------------------------------- Mon grep-find
(transient-define-prefix my-grep-find ()
  "Saisie guidée pour une recherche récursive d'une regex dans les fichiers à partir d'un répertoire."
  ["-------------------------------------------- Recherche de fichiers contenant une séquence"
   ["Find:"
    ("d" "Répertoire de départ" "start=" :init-value (lambda (obj) (oset obj value (replace-regexp-in-string
										    "/ssh:.*:/" "/"
										    (replace-regexp-in-string
										     "/sudo:.*:/" "/"
										     default-directory)))))
    ("f" "regexp Fichier" "fic=")
    (:info "Utiliser f pour retirer les noms de fichiers matchant regexp")
    (:info "Utiliser F pour ne garder que les noms de fichiers matchant une regexp")]
   ["Grep:"
    ("c" "regexp contenu fichier" "cont=")
    ("i" "ignorer Maj/Min" "-i")]
   [("r" "Lancer ma recherche" my-grep-find-run)
    ("k" "Garder les paramètres" transient-save)
    ("<f1>" "Quitter cette aide" transient-quit-one)]])

(defvar my-def-exclusion "" "conserve l'exclusion par défaut choisie par l'utilisateur")
(defun my-grep-find-run (params)
  (interactive (list (transient-args 'my-grep-find)))
  (let* ((param-assoc (extraire params))
	 (cmd (format "find %s -type f %s -exec grep --color=auto -nH --null %s -e %s \\{\\} +"
		      (format-param "start" "%s" "." param-assoc)
		      (format-param "fic" "-iname \"%s\"" "" param-assoc)
		      (format-param "noname" "%s" "" param-assoc)
		      (format-param "cont" "%s" "." param-assoc))))
    (setf my-def-exclusion (format-param "exc" "%s" "" param-assoc))
    (message "Commande: %s" cmd)
    (grep cmd)
    (delete-other-windows)
    (switch-to-buffer "*grep*")
    (local-set-key "f" 'filtre-grep)
    (local-set-key "F" 'select-grep)))

(defun filtre-grep (excl)
  "filter les résultats du dernier grep (suppression des matchs)"
  (interactive "sExclure du grep la regexp: ")
  (switch-to-buffer "*grep*")
  (delete-other-windows)
  (read-only-mode 0)
  (beginning-of-buffer)
  (flush-lines excl))

(defun select-grep (keep)
  "Selectionner les résultats du dernier grep (ne garder que les matchs)"
  (interactive "sNe garder du grep que la regexp: ")
  (switch-to-buffer "*grep*")
  (delete-other-windows)
  (read-only-mode 0)
  (beginning-of-buffer)
  (keep-lines keep))

;;-------------------------------------------------------- Lancements pour Ansible
(defvar selected-dir "/etc/ansible"
  "Répertoire courant pour ansible")
(defvar selected-playbook nil
  "Sélection d'un fichier de playbook")
(defvar selected-inventaire nil
  "Sélection utilisateur à prendre en priorité sur un inventaire de la liste prédéfinie")

(define-minor-mode ansible-mode
  "Consultation des logs d'ansible-run"
  :lighter " ans-log"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "<home>") 'beginning-of-buffer)
            (define-key map (kbd "C-c <select>") 'end-of-buffer)
	    (define-key map (kbd "C-c <up>") 'prev-fail)
	    (define-key map (kbd "C-c <down>") 'next-fail)
            map))

(require 'transient)
(global-set-key (kbd "C-c C-a") 'run-ansible)
(transient-define-prefix run-ansible ()
  "Saisie guidée des paramètres pour un lancement Ansible"
  ["-------------------------------------------- Ansible"
   ["Paramètres:"
    ("R" "Répertoire courant" select-dir
     ;;:init-value (lambda (obj) (oset obj value) default-directory)
     )
    (:info (lambda () (format "cur-rep: %s" selected-dir)))
    ("p" "Playbook" select-play)
    (:info (lambda () (format "playbook: %s" selected-playbook)))
    ("I" "liste d'inventaires" "inventaire-choix=" :choices ("/etc/ansible/inventory/" "/root/ansible/update-wildcard/host-wildcard.yml" "/root/ansible/migration-bases-oracle/"))
    ("i" "autre Inventaire" select-inv)
    (:info (lambda () (format "autre inventaire: %s" selected-inventaire)))
    ;;(:info 'show-inventaire)
    ("v" "variables à définir (ex passwd:val)" "vars=")
    ("l" "Limiter à un serveur" "limit=")]
   [("r" "Lancer la commande" run-ansible-cmd)
    ("k" "Garder ces paramètres" transient-save)
    ("ep" "Edit playbook" (lambda () (interactive) (find-file selected-playbook)))
    ("ei" "Edit inventaire" (lambda () (interactive) (find-file selected-inventaire)))
    ("er" "Edit roles" (lambda () (interactive) (find-file (format "%s/roles" selected-dir))))
    ("<f1>" "Quitter cette aide" transient-quit-one)]])

(transient-define-suffix select-dir ()
  "Choix d'un répertoire"
  :transient t
  (interactive)
  (setf selected-dir (lire-repertoire "Répertoire pour Ansible: "))
  (setf default-directory selected-dir))

(transient-define-suffix select-inv ()
  "Choix d'un inventaire"
  :transient t
  (interactive)
  (setf selected-inventaire (lire-fichier "Inventaire: " nil)))

(transient-define-suffix select-play ()
  "Choix d'un playbook"
  :transient t
  (interactive)
  (setf selected-playbook (lire-fichier "Playbook: " selected-playbook)))

(defun show-inventaire (params)
  "pour utilisation dans :info mais ne fonctionne pas"
  (interactive (list (transient-args 'run-ansible)))
  (let ((param-assoc (extraire params)))
    (format "Inventaire choisi: %s" (get-inventaire param-assoc))))

(defun get-inventaire (param-assoc)
  (or selected-inventaire
      (format-param "inventaire-choix" "%s" "" param-assoc)))

(defun run-ansible-cmd (params)
  "Lancement effectif de la commande cmd construite à partir des paramètres du transient avec envoi des logs dans un buffer *ansible-log*"
  (interactive (list (transient-args 'run-ansible)))
  (let* ((param-assoc (extraire params))
	 (cmd (format "%s/usr/local/bin/ansible-playbook -i %s %s%s%s"
		      "" ;;"eval `keychain --noask --eval id_ed25519_ans`; "
		      (get-inventaire param-assoc)
		      (or selected-playbook (lire-fichier "Playbook: " selected-playbook))
		      (string-replace ":" "=" (format-param "vars" " --extra-vars %s" "" param-assoc))
		      (format-param "limit" " -l %s.intranet.rouen.fr" "" param-assoc))))
    (message "Cmd: %s" cmd)
    (run-cmd-buff cmd "*ansible-log*" "ansible-run")))

(defun run-cmd-buff (cmd buf nom)
  "Affiche cmd puis cette commande (process nommé nom) qui
inclue des paramètres,et garde les logs dans un buffer nommé buf.
Il n'est plus nécessaire de passer en user adminansible via root !"
  ;; (let ((full-cmd (format "sudo -E -s -u adminansible %s" cmd)))
  ;;   )
  (with-current-buffer (get-buffer-create buf)
      ;;(message "Commande: %s" cmd)
    (read-only-mode 0)
    (erase-buffer)
      (insert (format "# %s\n# %s\n# Lancé le %s\n\n"
		      nom
		      cmd
		      (current-time-string)))
      (switch-to-buffer buf)
      (delete-other-windows)
      (start-process-shell-command nom buf cmd)
      ;;(sudo-shell-command buf (or le-mdp (read-passwd "Mot de passe adminXXX: ")) nom full-cmd)
      ;;(sudo-shell-command buf (or le-mdp (read-passwd "Mot de passe adminXXX: ")) nom "sudo -i -u adminansible whoami"))
      (ansible-mode 1)))

(defun sudo-shell-command (buffer password nom command)
  "Lance une commande en sudo root.
Gardé pour d'éventuels futurs besoins"
  (let ((proc (start-process-shell-command
               nom
               buffer
               (concat "sudo bash -c "
                       (shell-quote-argument command))
	       )))
    (process-send-string proc password)
    (process-send-string proc "\r")
    (process-send-eof proc)
    ))

(define-minor-mode ansible-mode
  "Consultation des logs d'ansible-run"
  :lighter " ans-log"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "<home>") 'beginning-of-buffer)
            (define-key map (kbd "M-<prior>") 'beginning-of-buffer)
            (define-key map (kbd "M-<next>") 'end-of-buffer)
	    (define-key map (kbd "S-<up>") 'prev-fail)
	    (define-key map (kbd "S-<down>") 'next-fail)
	    (define-key map (kbd "s") 'helm-occur)
	    (define-key map (kbd "f") 'flush-lines)
	    (define-key map (kbd "k") 'keep-lines)
	    map))

(defun next-fail ()
  (interactive)
  (search-forward-regexp "FAILED *[^=]")
  ;;(search-forward-regexp "emacs[^epr\\.]")
  )
(defun prev-fail ()
  (interactive)
  (search-backward-regexp "FAILED *[^=]")
  ;;(search-backward-regexp "ema")
  )

;;-------------------------------------------------------- SSH vers serveur mairie
(transient-define-prefix my-ssh ()
  "Saisie guidée des paramètres pour une connexion SSH à un serveur Mairie de Rouen"
  ["-------------------------------------------- SSH consoles, répertoires et terminaux"
   ["Paramètres:"
    ("s" "Serveur" "srv=")
    ("r" "Répertoire initial" "rep=")
    ("b" "Nom de la base de donnée" "base=")
    ("u" "Utilisateur" "user=")
   ]
   ["lancement:"
    ("c" "Console SSH" topen-ssh-console)
    ("d" "Directory SSH" topen-ssh-directory)
    ("t" "Ouvrir un terminal std pour commandes TUI" topen-ssh-term)
    ("i" "init SSH quand bloqué" init-ssh)
    ("k" "Garder les paramètres" transient-save)
    ("<f1>" "Quitter cette fenêtre" transient-quit-one)]])

(defvar-local choosen-srv nil "Serveur demandé")
(defvar-local choosen-default-dir nil "Répertoire demandé")
(defvar-local choosen-base nil "Dernière base demandée")

(defun cli(cmd &optional buffer)
  (comint-send-string (if buffer buffer (buffer-name)) (format "%s\n" cmd)))

(defun pn (obj)
  ""
  (if obj
      obj
    "(pas de valeur)"))

(defun topen-ssh-term (params)
  "Pour appel depuis transient"
  (interactive (list (transient-args 'my-ssh)))
  (let* ((param-assoc (extraire params))
	 (srv (format-param "srv" "%s" "localhost" param-assoc)))
    (open-ssh-term srv)))

(defun open-ssh-term (srv)
  (interactive)
  (message "Connexion SSH demandée pour %s en terminal sur %s" user-login-name (pn srv))
  (tramp-term (list user-login-name srv)))

(defun topen-ssh-console (params)
  "Pour appel depuis transient"
  (interactive (list (transient-args 'my-ssh)))
  (message "Paramètres pour open-ssh-console: %s" params)
  (let* ((param-assoc (extraire params))
	 (srv (format-param "srv" "%s" "localhost" param-assoc))
	 (rep (format-param "rep" "%s" "/" param-assoc))
	 (base (format-param "base" "%s" nil param-assoc))
	 (user (format-param "user" "%s" nil param-assoc)))
    (open-ssh-console srv rep base user)))

(defun open-ssh-console (srv rep base &optional user)
  (interactive)
  (let ((nombuf (if base
		    (format "*shell %s %s*" srv base)
		  (format "*shell %s*" srv))))
    (message "Connexion SSH demandée par %s vers %s répertoire %s base %s" (pn user)  (pn srv) (pn rep) (pn base))
    (cond ((get-buffer nombuf)      ; Afficher le buffer et passer dans le répertoire demandé
	   (switch-to-buffer nombuf)
	   (cli (format "cd %s" rep)))
	  (t			    ; Ouvrir la connexion SSH demandée
	   (let ((default-directory (if user (format "/ssh:%s@%s:%s" user srv rep)
				      (format "/ssh:%s|sudo:%s:%s" srv srv rep))))
	     (sleep-for 0.2)
	     (shell nombuf))
	   ))
    (cli "export PS1=\"\\$(whoami)@$(hostname) \\$(pwd) \\\\$ \"")
    (setq choosen-srv srv)
    (setq choosen-default-dir rep)
    (setq choosen-base base)))

(defun topen-ssh-directory (params)
  "Pour appel depuis transient"
  (interactive (list (transient-args 'my-ssh)))
  (message "Paramètres pour open-ssh-directory: %s" params)
  (let* ((param-assoc (extraire params))
	 (srv (format-param "srv" "%s" "localhost" param-assoc))
	 (rep (format-param "rep" "%s" "/" param-assoc))
	 (base (format-param "base" "%s" nil param-assoc)))
    (message "Dired SSH demandé vers %s répertoire %s" (pn srv) (pn rep))
    (message "open-ssh-directory: %s sur %s" rep srv)
    (open-ssh-directory srv rep base)
    ))

(defun open-ssh-directory (srv rep &optional base)
  (interactive)
  (message "Dired SSH demandé vers %s répertoire %s, base %s" (pn srv) (pn rep) (pn base))
  (dired (format "/ssh:%s|sudo:%s:%s" srv srv rep)) ; ex: /ssh:Mod-debian12|sudo:Mod-debian12:/var/log/bin/sh
  )

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

;;-------------------------------------------------------- Aide pour dired
(transient-define-prefix my-dired ()
  "Aide pour utiliiser dired"
  ["-------------------------------------------- Aide dired"
   ["lettres pour commandes:"
    ("<ret>" "remplacer dired courant par celui de la ligne" dired-find-file :transient t)
    ("a" "ouvrir dired sur la ligne, conserver buffer courant" dired-find-alternate-file :transient t)
    ("D" "Delete (la ligne ou la sélection)" dired-do-delete :transient t)
    ("O" "changer Owner (ex: www-data:www-data)" dired-do-chown :transient t)
    ("M" "changer le Mode (ex: a+x,g-r)" dired-do-chmod :transient t)
    ("C" "Copier fichier/rep (haut/bas choisir rep d'un autre dired)" dired-do-copy :transient t)
    ("m" "mark, selectionner ligne en cours" dired-mark :transient t)
    ("u" "umark, déselectionner ligne en cours"dired-unmark :transient t)
    ("%m" "selectionner des fichiers par une regexp" dired-mark-files-regexp :transient t)
    ]
   ["Divers :"
    ("<up>" "ligne précédente" dired-previous-line :transient t)
    ("<down>" "ligne suivante" dired-next-line :transient t)
    ("<f1>" "Quitter cette fenêtre" transient-quit-one)]
   ])

;;-------------------------------------------------------- Aide pour helm-buffer-list
(transient-define-prefix aide-²f ()
  "Précise les possibilités de recherche d'un buffer, et autre"
  ["-------------------------------------------- Aide complémentaire"
   ["Filtres possibles - cumulable, séparés par espace:"
    (:info "lettres: par noms de fichiers / srv qui contiennent")
    (:info "*lettres: par modes (*dir répertoire, *ya YAML, *sh Shell, *ter Terminal)")
    (:info "@lettres: retenir les buffers dont le contenu contient lettres")
    (:info "/lettres: retenir les buffers dont le répertoire contient lettres")
    (:info "exemple *ya apt: propose uniquement les buffers avec des fichiers YAML contenant apt:")
    ]
   ["Autres raccourcis"
    ("<tab>" "afficher les autres actions possible" helm-select-action)
    (:info "C-Espace sélectionner la ligne")    
    (:info "C-c d fermer les buffers sélectionnés ou la ligne")    
    ("<f1>" "Quitter cette fenêtre" transient-quit-one)]])

;;-------------------------------------------------------- Accueil Aide
;;(load-library "~/elisp/train")
(transient-define-prefix my-transients ()
  "Saisie guidée des paramètres pour un lancement Ansible"
  ["-------------------------------------------- Accueil Aide"
   ["Commandes prémachées:"
    ("s" "SSH vers srv" my-ssh)
    ("g" "Find+Grep" my-grep-find)
    ("a" "Ansible run" run-ansible)
    ("c" "casual calc" casual-calc-tmenu)
    ("d" "dired" my-dired)
    ("D" "Dired plus" casual-dired-tmenu)
    ;;("r" "Export Revealjs" org-re-reveal-export-to-html)
    ("i" "Casual Info" casual-info-tmenu)]
   ["Touches de fonction (F1: cette aide)"
    ("<f1>" "Quitter cette aide - F1 la réafficher" transient-quit-one)
    ("<f2>" "Eval buffer - Shift paredit" eval-buffer)
    ("<f3>" "Définir macro" kmacro-start-macro-or-insert-counter)
    ("<f4>" "Fin def macro / run" kmacro-end-or-call-macro)
    ("<f5>" "F5 Revert - rafraichir" (lambda () (interactive) (revert-buffer t t)))
    ("<f6>" "Occur" helm-occur)
    ("<f7>" "Mot de passe - Shift Reset" mot-de-passe)
    ("S" "C-c s edit en root (C-u C-c s autre user)" sudo-edit)]
   ;;("8" "F8" "Wahoo" train-transient)
   ["Fenêtres"
    ("O" "Only - cette fenêtre" delete-other-windows)
    ("3" "Diviser verticalement" split-window-right)    
    ("2" "Diviser horizontalement" split-window-below)    
    ("F" "Fermer / cacher buffer" delete-window)
    ("X" "Fermer / fermer buffer" fermer-buffer)
    ("A" "Agrandir" (lambda () (interactive) (enlarge-window 1)) :transient t)
    ("D" "Diminuer" (lambda () (interactive) (enlarge-window -1)) :transient t)
    ("G" "Grossir" (lambda () (interactive) (enlarge-window-horizontally 1)) :transient t)
    ("M" "Maigrir" (lambda () (interactive) (shrink-window-horizontally 1)) :transient t)]
   ["Touche ²"
    ("²²" "fenêtre suivante" other-window)
    ("²f" "Choisir un buffer" helm-buffers-list)    
    ("²F" "Aide pour ²f, autre" aide-²f)    
    ("²b" "Choisir DB par nom" choisir-base)
    ("²B" "Choisir DB par appli" choisir-alias)
    ("²o" "commande Oracle" helm-oracle)
    ("²O" "Requête SQL Oracle" ora-sql-cmd)
    ("²p" "prompt SQLPlus (bascule)" ora-sqlplus)
    ("²s" "bases d'un srv" srv-to-bases)
    ]])

(defun en-attente ()
  (interactive)
  (message "Raccourci non encore défini: prévu bientôt"))

;; Définir les raccourcis annoncés ci dessus
(define-prefix-command 'pde-map)
(global-set-key "²" pde-map)
(global-set-key "²²" 'other-window)
(global-set-key "²f" 'helm-buffers-list)
(global-set-key "²&" 'petit-eshell)
(global-set-key "²é" 'ffap)
(global-set-key (kbd "²b") 'choisir-base)
(global-set-key (kbd "²B") 'choisir-alias)
(global-set-key (kbd "²o") 'helm-oracle)
(global-set-key (kbd "²O") 'ora-sql-cmd)
(global-set-key (kbd "²s") 'srv-to-bases)
(global-set-key (kbd "<f1>") 'my-transients)
(global-set-key (kbd "<f2>") 'eval-buffer)
(global-set-key (kbd "S-<f2>") 'paredit-mode)
(global-set-key (kbd "<f5>") (lambda () (interactive) (revert-buffer nil t)))
(global-set-key (kbd "<f6>") 'helm-occur)
(global-set-key (kbd "<f7>") 'mot-de-passe)
(global-set-key (kbd "S-<f7>") 'reset-mdp)
;;(global-set-key (kbd "<f8>") 'train-transient)
(global-set-key (kbd "C-c s") 'sudo-edit)

(find-file "/etc/ansible")
(my-transients)
