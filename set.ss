(module set mzscheme
  (provide
   make-set
   is-present?
   add!)

  (define (make-set . words)
    (let ((rv (make-hash-table 'equal)))
      (for-each (lambda (word) (add! word rv))
                words)
      rv))

  (define (is-present? word set)
    (hash-table-get set word (lambda () #f)))

  (define (add! word set)
    (hash-table-put! set word #t)
    set))
