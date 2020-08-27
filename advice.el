;;; -*- lexical-binding: t; -*-

;;; Skip Emacs's own package verification and let Nix do it for us.
;;;
;;; Having gnupg around the build triggers Emacs to use it for package signature
;;; verification. This would not work anyway because the build sandbox does not
;;; have a properly configured user home and environment.
(require 'advice)
(when noninteractive
  (after! undo-tree
    (global-undo-tree-mode -1)))

(setq package-check-signature nil)

(advice-add 'nix-straight-get-used-packages
            :before (lambda (&rest r)
                      (message "[nix-doom-emacs] Advising doom installer to gather packages to install...")
                      (advice-add 'doom-autoloads-reload
                                  :override (lambda (&optional file force-p)
                                              (message "[nix-doom-emacs] Skipping generating autoloads...")))
                      (advice-add 'doom--print
                                  :override (lambda (output)
                                            (message output)))))

(advice-add 'y-or-n-p
            :override (lambda (q)
                        (message "%s \n[nix-doom-emacs] --> answering NO" q)
                        nil))

;;; org is not installed from git, so no fixup is needed
(advice-add '+org-fix-package-h
            :override (lambda (&rest r)))

;; just use straight provided by nix
(advice-add 'doom-initialize-core-packages
            :override (lambda (&rest r) (require 'straight)))
