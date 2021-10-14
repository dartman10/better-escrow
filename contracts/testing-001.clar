(define-map squares { x: int } { square: int })
;;(define-map squares { x: int } { square: int })

(define-public (add-entry (x int))
  (begin
    (map-insert squares { x: x} { square : (* x x)})
    (ok (map-get? squares {x: x}))
    ;;(ok "fine")
  )
)

;;((define-public add-entry (x int)
;;  (map-insert squares { x: 2 } { square: (* x x) })))


;;(add-entry 1)
;;(add-entry 2)
;;(add-entry 3)
;;(add-entry 4)
;;(add-entry 5)