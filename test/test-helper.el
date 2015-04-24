(require 'f)

(defvar helm-ledger-root-path
  (f-parent (f-dirname load-file-name)))

(add-to-list 'load-path helm-ledger-root-path)

(require 'undercover)
(undercover "*.el")

(require 'helm-ledger)

