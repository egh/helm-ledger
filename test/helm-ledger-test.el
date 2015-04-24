;;; Code:

(ert-deftest helm-ledger--make-process-string-test ()
  (let ((helm-pattern "foo"))
    (should (equal "ledger bal foo" (helm-ledger--make-process-string "bal"))))
  (let ((helm-pattern "foo"))
    (should (equal "ledger reg foo" (helm-ledger--make-process-string "reg"))))
  (let ((helm-pattern "foo")
        (helm-ledger--filter 'payee))
    (should (equal "ledger reg payee foo"
                   (helm-ledger--make-process-string "reg")))))
