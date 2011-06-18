(module dfs mzscheme
  (require (only (lib "1.ss" "srfi") append-map remove))
  (provide generic-dfs)

  (define (generic-dfs start-node enumerate-neighbors path-to-here goal-node? set-visited! visited?)
    (if (not (visited? start-node))
        (begin
          (set-visited! start-node path-to-here)
          (if (goal-node? start-node)
              (list (reverse  path-to-here))
            (let ((neighs (remove visited? (enumerate-neighbors start-node))))
              (append-map (lambda (n)
                            (generic-dfs
                             n
                             enumerate-neighbors
                             (cons start-node path-to-here)
                             goal-node?
                             set-visited!
                             visited?))
                          neighs))))
      '())))

