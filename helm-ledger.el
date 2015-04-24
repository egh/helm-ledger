;;; helm-ledger.el --- search ledger via helm

;; Copyright (C) 2015 Erik Hetzner

;; Author: Erik Hetzner
;; Package-Requires: ((helm "1.6.0") (hydra "0.12.0")

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; a helm interface ledger, a powerful, double-entry accounting system
;; <http://www.ledger-cli.org/>

;;; Code:

(require 'helm)
(require 'hydra)

(defvar helm-ledger-help-message
  "\n* Helm Ledger\n
\n** Helm Ledger tips:

\n** Specific commands for Helm Ledger:\n
\\<helm-ledger-map>
\\[helm-ledger-filter-payee]\t->Filter by payee, not account.
\n** Helm Map\n
\\{helm-map}")

(defhydra helm-ledger-hydra-menu
  (:exit t)
  "
Helm Ledger options
"
  ("p" helm-ledger-filter-payee "filter by payee")
  ("a" helm-ledger-filter-account "filter by account"))

(defvar helm-ledger-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map helm-map)
    (define-key map (kbd "C-c ?") 'helm-ledger-help)
    (define-key map (kbd "C-c C-c") #'helm-ledger-hydra-menu/body)
    map)
  "Keymap for `helm-ledger'.")

(defun helm-ledger-help ()
  "Display help for `helm-ledger'."
  (interactive)
  (let ((helm-help-message helm-ledger-help-message))
    (helm-help)))

(defvar helm-ledger--filter 'account
  "Currently active filter type for `helm-ledger'.")

(defun helm-ledger--make-filter (name)
  "Make a function will set `helm-ledger--filter' to NAME."
  (let ((defun-name (intern (format "helm-ledger-filter-%s" name)))
        (docstring (format "Make helm-ledger filter by %s." name)))
    (eval `(defun ,defun-name nil
             ,docstring
             (interactive)
             (if helm-alive-p
                 (setq helm-ledger--filter (quote ,name)))
             (helm-update)))))

(helm-ledger--make-filter 'payee)
(helm-ledger--make-filter 'account)

(defun helm-ledger--make-process (cmd)
  "Return ledger process with the top level CMD."
  (let ((process-connection-type nil))
    (start-process-shell-command "helm-ledger" "*helm-ledger*"
                                 (helm-ledger--make-process-string cmd))))

(defun helm-ledger--make-process-string (cmd)
  "Return a process string for ledger with the top level CMD."
  (let ((args
         (cond ((eq helm-ledger--filter 'account)
                (format "%s" helm-pattern))
               ((eq helm-ledger--filter 'payee)
                (format "payee %s" helm-pattern)))))
    (format "ledger %s %s" cmd args)))

(defvar helm-source-ledger-bal
  (helm-build-async-source "Balance"
    :delayed t
    :requires-pattern 3
    :candidates-process (lambda ()
                          (helm-ledger--make-process "bal"))))

(defvar helm-source-ledger-reg
  (helm-build-async-source "Register"
    :delayed t
    :requires-pattern 3
    :candidates-process (lambda ()
                          (helm-ledger--make-process "reg"))))

(defun helm-ledger ()
  "Interactively interrogate ledger with helm."
  (interactive)
  (setq helm-ledger--filter 'account)
  (helm :sources
        '(helm-source-ledger-bal
          helm-source-ledger-reg)
        :keymap helm-ledger-map))

(provide 'helm-ledger)
;;; helm-ledger.el ends here
