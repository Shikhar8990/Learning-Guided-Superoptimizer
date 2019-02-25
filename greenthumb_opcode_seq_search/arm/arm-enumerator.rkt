#lang racket

(require "../machine.rkt" "../enumerator.rkt" "arm-machine.rkt")
(require racket/generator)

(provide arm-enumerator%)

(define arm-enumerator%
  (class enumerator%
    (super-new)
    (inherit-field machine)
    
    (define cmp-inst (get-field cmp-inst machine))

    (define/override (get-pruning-info state-vec) (progstate-z state-vec))
    
    (define/override (filter-with-pruning-info opcode-pool flag-in flag-out
                                               #:no-args [no-args #f] #:try-cmp [try-cmp #f])
      (define ret
        (cond
         [try-cmp
          (cond
           ;; flags are different, need to insert cmp instructions.
           [(and (number? flag-in) (list? flag-out)
                 (not (member flag-in flag-out)))
            (filter (lambda (ops-vec) (member (vector-ref ops-vec 0) cmp-inst)) opcode-pool)]

           ;; no conditional flag, don't use conditional opcodes.
           [(equal? flag-in -1)
            (filter (lambda (ops-vec) (= (vector-ref ops-vec 1) -1)) opcode-pool)]

           ;; no restriction.
           [else opcode-pool]
           )
          ]

         [else
          ;; don't use cmp instructions and conditional opcodes.
          (filter (lambda (ops-vec)
                    (and (not (member (vector-ref ops-vec 0) cmp-inst))
                         (= (vector-ref ops-vec 1) -1)))
                  opcode-pool)
          ]))

      (if no-args
          ;; don't enumerate conditional opcodes
          (filter (lambda (ops-vec) (= -1 (vector-ref ops-vec 1))) ret)
          ret)
      )
    
    ;;name of the file
		(define inFile "dum")

		;;read a file containing the suggestions
		(define (get-bulk-pruned-opcodes filename progSize)
			(define numSuggest 620)
			(define lala '())
      (define dum (string-append filename (number->string progSize)))
			(define in (open-input-file dum))
			(for ([i numSuggest])
				[set! lala (append lala (list (read-line in)))])
			(close-input-port in)
			lala)

		;;get the pruning suggestions in a list
		(define/override (filter-with-bulk-pruning opcode-pool pSize)
  		(get-bulk-pruned-opcodes inFile pSize)
  	)

    ))
