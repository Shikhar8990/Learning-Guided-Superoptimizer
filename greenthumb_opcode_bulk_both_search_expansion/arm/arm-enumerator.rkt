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
    
		;;read a file containing the suggestions
		(define inFile "dum")
		(define priorityList '())
    (define newL1 '())
		(define (get-bulk-pruned-opcodes-priority filename)
			(define numSuggest 10000)
      (set! priorityList '())
			(define in (open-input-file filename))
			(for ([i numSuggest])
        (set! newL1 (read-line in))
        #:break (equal? newL1 eof)
				[set! priorityList (append priorityList (list newL1))])
			(close-input-port in)
			priorityList)

		(define pruneList '())
    (define inPruneFile "pruneDum")
    (define origOpCodePool "OrigOpPool")
    (define newL '())
		(define (get-bulk-pruned-opcodes-pruning opcode-pool filename)
      
      (define out (open-output-file origOpCodePool #:exists 'replace))
      (for ([op (in-list opcode-pool)])
        (write op out))
      (close-output-port out)

      (system "python2 generateTopNSugesstions4Pruning.py opcodeListFile resFile OrigOpPool --topK 10")
      (system "cp sugg_encoded_top10 pruneDum")

			(define numSuggest 10000)
      (set! pruneList '())
      (set! newL '())

			(define in (open-input-file filename))
			(for ([i numSuggest])
        (set! newL (read-line in))
        #:break (equal? newL eof)
				[set! pruneList (append pruneList (list newL))])
			(close-input-port in)
			pruneList)

		;;get the pruning suggestions in a list
		(define/override (filter-with-bulk-pruning opcode-pool prune)
      (if (equal? prune #f)
  		  (get-bulk-pruned-opcodes-priority inFile)
        (get-bulk-pruned-opcodes-pruning opcode-pool inPruneFile))
  	)
    ))
