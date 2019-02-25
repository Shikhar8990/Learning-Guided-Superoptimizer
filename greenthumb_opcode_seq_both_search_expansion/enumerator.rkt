#lang racket

(require "inst.rkt")
(require racket/generator)
(provide enumerator% all-combination-list all-combination-gen)


;; Return a list of all possible combinations of flat lists
(define (all-combination-list list-of-list)
  (define ret (list))
  (define (recurse in-list out-list)
    (cond
     [(empty? in-list) (set! ret (cons out-list ret))]
     [else
      (let ([rest (cdr in-list)]
            [x (car in-list)])
        (if (or (vector? x) (list? x))
            (for ([val x])
                 (recurse rest (cons val out-list)))
            (recurse rest (cons x out-list))))
      ]))

  (recurse (reverse list-of-list) (list))
  ret)

;; Return a generator of all possible combinations of flat lists
(define (all-combination-gen list-of-list)
  (define iterator
    (generator 
     ()
     (define (recurse in-list out-list)
       (cond
        [(empty? in-list) (yield out-list)]
        [else
         (let ([rest (cdr in-list)]
               [x (car in-list)])
           (if (or (vector? x) (list? x))
               (for ([val x])
                    (recurse rest (cons val out-list)))
               (recurse rest (cons x out-list))))
         ]))
     (recurse (reverse list-of-list) (list))
     (yield #f)
     ))

  iterator)

(define numInst 0)
(define enumerator%
  (class object%
    (super-new)
    (init-field machine printer)
    (public generate-inst get-pruning-info filter-with-pruning-info filter-with-bulk-pruning)

    (define (get-pruning-info state) #f)
    
    (define opcodes (get-field opcodes machine))

    (define (filter-with-pruning-info opcodes prune-in prune-out
                                      #:no-args [no-args #f] #:try-cmp [try-cmp #f])
      opcodes)

    ;; bulk pruning model
    (define (filter-with-bulk-pruning opcode-pool pSize prunemy)
      opcode-pool)
    
    ;; Mode `no-args is for generating instructions to be used for creating
    ;; inverse behaviors, so we don't have to enumerate variables/registers.
    ;; 
    ;; Examples of all possible instrucions with opcode add# that
    ;; the generator has to yeild.
    ;; Assume our program state has 3 variables/registers
    ;; const-range = #(0 1 -1), live-in = #(#t #t #f), live-out = #(#f #t #t)
    ;; (If live-in = #f, then everything is live. Similar for live-out.)
    ;; 
    ;; In mode `basic, yield all combinations of
    ;; (inst add#-id #({1 or 2} {0 or 1} {0, 1, or -1}))
    ;;
    ;; In mode `no-args, live-in and live-out don't matter.
    ;; (inst add#-id #(2 0 {0, 1, or -1}))
    ;; Only enumerate const and not variables, but make sure to assign
    ;; different IDs for the variables.
    (define (generate-inst live-in live-out prune-in prune-out pSize
                           #:no-args [no-args #f] #:try-cmp [try-cmp #f]
                           #:step-fw [step-fw #f] #:step-bw [step-bw #f]
                           #:prunemy [prunemy #f])

      (define mode (cond [no-args `no-args] [else `basic]))

      (define opcode-pool
        (cond
         [(and step-fw step-bw)
          ;;(pretty-display `(gen-pos ,step-fw ,(+ step-fw step-bw 1)))
          (send machine get-valid-opcode-pool step-fw (+ step-fw step-bw 1) live-in)]
         [else (get-field opcode-pool machine)]))
      ;; (define inst-choice '(! @+ a!))
      ;; (define opcode-pool (map (lambda (x) (send machine get-opcode-id x)) inst-choice))

      (set! opcode-pool (filter-with-pruning-info opcode-pool prune-in prune-out
                                                  #:no-args no-args
                                                  #:try-cmp try-cmp))


      ;; isMember function to check if an item is in a list or not
      (define (isMember str strs) (if [member str strs] #t #f))
      (define (isNotMember str strs) (if [member str strs] #f #t))

      ;; PRIORITIZING
      (when (equal? prunemy #f)
        (define opcode-pool-words '())
        (fprintf (current-output-port) "PRIORITIZING STAGE\n")
        (fprintf (current-output-port) "Original Opcode Pool: \n")
        (fprintf (current-output-port) "Length : ")
        (pretty-display pSize)
        ;(pretty-display opcode-pool)
        (for ([opCodeId (in-list opcode-pool)])
          ;(pretty-display (send machine get-opcode-name opCodeId)))
          ;(set! opcode-pool-words (append opcode-pool-words 
                                    ;(list (send machine get-opcode-name opCodeId)))))
          ;(pretty-display opCodeId) 
          (fprintf (current-output-port) "~a " opCodeId) 
          (pretty-display (send machine get-opcode-name opCodeId)))
          ;(pretty-display opcode-pool-words)
        (fprintf (current-output-port) "\n")
        (fprintf (current-output-port) "End Pruned Original Opcode Pool\n")

        ;; get the opcode pool suggested by the bulk pruning 
        (define newSuggestion '())
        (define newVecList '())
        (define newOpcodeIdList '())
        (define new-opcode-pool (filter-with-bulk-pruning opcode-pool pSize prunemy))
        (fprintf (current-output-port) "Suggestion Pool:\n")
        (pretty-display new-opcode-pool)
        (fprintf (current-output-port) "Program Size : ")
        (pretty-display pSize)
        (for ([sugges (in-list new-opcode-pool)]) 
          (pretty-display sugges)
          (set! newOpcodeIdList '())
          ;; new code to convert a space sperated string to a num vector
          (set! newSuggestion sugges)
          (define opTokens (string-split newSuggestion))
          (for ([x (in-list opTokens)])
            (set! newOpcodeIdList (append newOpcodeIdList (list (string->number x)))))
          (define opCodeVec (list->vector newOpcodeIdList))
          (set! newVecList (append newVecList (list opCodeVec)))
          (pretty-display (send machine get-opcode-name opCodeVec)))
        ;; end new code 
        (fprintf (current-output-port) "End Suggestion Pool:\n")
        ;;(pretty-display newVecList)
        ;;(fprintf (current-output-port) "\n")

        (define hiPriority '())
        (define lowPriority '())
        (define toPrioritize '())

        ;; lPrune - making low priority all opcodes that are not in the
        ;; suggestions
        (define (genOrderedSeq1 lPool lPrune)
          (set! lowPriority '())
          (set! toPrioritize '())
          (for ([x (in-list lPool)])
            (if (isNotMember x lPrune)
              (set! lowPriority (append lowPriority (list x)))
              (set! toPrioritize (append toPrioritize (list x))))))

        (genOrderedSeq1 opcode-pool newVecList)

        ;; lPrune - making high priority all opcodes that are in the suggestion
        ;; list as well the the opcode pool
        (define (genOrderedSeq2 lPool lPrune)
          (set! hiPriority '())
          (for ([x (in-list lPrune)])
            (cond [(and (isMember x lPool) (isNotMember x hiPriority))
              (set! hiPriority (append hiPriority (list x)))])))
        ;;(set! lowPriority (append lowPriority (list x)))

        ;;(genOrderedSeq2 opcode-pool newVecList)
        (genOrderedSeq2 toPrioritize newVecList)

        (fprintf (current-output-port) "High priority \n")
        (pretty-display hiPriority)
        (pretty-display (length  hiPriority))

        (fprintf (current-output-port) "Low priority \n")
        (pretty-display lowPriority)
        (pretty-display (length  lowPriority))

        (fprintf (current-output-port) "To priority \n")
        ;;(pretty-display lowPriority)
        (pretty-display (length  toPrioritize))

        (define orderedPool (append hiPriority lowPriority)) 
        (set! opcode-pool (append hiPriority lowPriority)) 

        (fprintf (current-output-port) "Prioritized Opcode Pool \n")
        (pretty-display opcode-pool)
        (fprintf (current-output-port) "Length : ")
        (pretty-display pSize)
        (fprintf (current-output-port) "End Prioritized Opcode Pool \n"))

      ;;PRUNING
      (when (equal? prunemy #t)
        (define opcode-pool-words '())
        (fprintf (current-output-port) "PRUNING STAGE\n")
        (fprintf (current-output-port) "Original Opcode Pool: \n")
        (fprintf (current-output-port) "Length : ")
        (pretty-display (length  opcode-pool))
        ;(pretty-display opcode-pool)
        (for ([opCodeId (in-list opcode-pool)])
          ;(pretty-display (send machine get-opcode-name opCodeId)))
          ;(set! opcode-pool-words (append opcode-pool-words 
                                    ;(list (send machine get-opcode-name opCodeId)))))
          ;(pretty-display opCodeId) 
          (fprintf (current-output-port) "~a " opCodeId) 
          (pretty-display (send machine get-opcode-name opCodeId)))
          ;(pretty-display opcode-pool-words)
        (fprintf (current-output-port) "\n")
        (fprintf (current-output-port) "End Pruned Original Opcode Pool\n")

        ;; get the opcode pool suggested by the bulk pruning 
        (define newSuggestion '())
        (define newVecList '())
        (define newOpcodeIdList '())
        (define new-opcode-pool (filter-with-bulk-pruning opcode-pool pSize prunemy))
        (fprintf (current-output-port) "Suggestion Pool:\n")
        (pretty-display new-opcode-pool)
        (fprintf (current-output-port) "Length : ")
        (pretty-display (length  new-opcode-pool))
        (for ([sugges (in-list new-opcode-pool)]) 
          (pretty-display sugges)
          (set! newOpcodeIdList '())
          ;; new code to convert a space sperated string to a num vector
          (set! newSuggestion sugges)
          (define opTokens (string-split newSuggestion))
          (for ([x (in-list opTokens)])
            (set! newOpcodeIdList (append newOpcodeIdList (list (string->number x)))))
          (define opCodeVec (list->vector newOpcodeIdList))
          (set! newVecList (append newVecList (list opCodeVec)))
          (pretty-display (send machine get-opcode-name opCodeVec)))
        ;; end new code 
        (fprintf (current-output-port) "End Suggestion Pool:\n")
        ;;(pretty-display newVecList)
        ;;(fprintf (current-output-port) "\n")
        
        (define hiPriority '())
        (define lowPriority '())
        (define toPrioritize '())

        ;; lPrune - making high priority all opcodes that are in the suggestion
        ;; list as well the the opcode pool
        (define (genOrderedSeq2 lPool lPrune)
          (set! hiPriority '())
          (for ([x (in-list lPrune)])
            (cond [(and (isMember x lPool) (isNotMember x hiPriority))
              (set! hiPriority (append hiPriority (list x)))])))

        ;;(genOrderedSeq2 opcode-pool newVecList)
        (genOrderedSeq2 opcode-pool newVecList)

        (fprintf (current-output-port) "High priority \n")
        (pretty-display hiPriority)
        (pretty-display (length  hiPriority))

        (fprintf (current-output-port) "Low priority \n")
        (pretty-display lowPriority)
        (pretty-display (length  lowPriority))

        (fprintf (current-output-port) "To prioritize \n")
        ;;(pretty-display lowPriority)
        (pretty-display (length  toPrioritize))

        (define orderedPool (append hiPriority lowPriority)) 
        (set! opcode-pool (append hiPriority lowPriority)) 

        (fprintf (current-output-port) "Prioritized Opcode Pool \n")
        (pretty-display opcode-pool)
        (fprintf (current-output-port) "Length : ")
        (pretty-display (length  opcode-pool))
        (fprintf (current-output-port) "End Prioritized Opcode Pool \n"))
      
      ;;(pretty-display `(generate-inst ,(length opcode-pool) ,(length (get-field opcode-pool machine))))
      ;;(pretty-display (map (lambda (x) (send machine get-opcode-name x)) opcode-pool))

      (define iterator
        (generator 
         ()
         (define (finalize args)
           (define in -1)
           (for/list
            ([arg args])
            ;; If arg is `var, assign fresh ID.
            (cond
             [(symbol? arg) (set! in (add1 in)) in]
             [else arg])))
         
         (define (enumerate opcode-id ranges)
           ;; Get all combinations of args
           (for ([args (all-combination-list ranges)])
                (let* ([new-args (finalize args)]
                       [pass (send machine is-cannonical opcode-id new-args)])
                  (when
                   pass
                   (let* ([my-inst (inst opcode-id (list->vector new-args))]
                          [new-live-in
                           (and live-in (send machine update-live live-in my-inst))]
                          [new-live-out
                           (and live-out (send machine update-live-backward live-out my-inst))])
                      	;;shikhar
                  			(fprintf (current-output-port) "Inst:")
                  			(send printer print-syntax-inst (send printer decode-inst my-inst))
                  			(pretty-display (format "Arguments = ~a " new-args))
                  			;(fprintf (current-output-port) "\n")
                  			(set! numInst (add1 numInst))
                  			(pretty-display (format "\nIcount = ~a" numInst))
                  			;;(fprintf (current-output-port) "\n") 
                  			;;end shikhar 
                        
                     (yield (list my-inst new-live-in new-live-out)))))))
       
         ;(for ([opcode-id (shuffle opcode-pool)])
         (for ([opcode-id (in-list opcode-pool)])
							(fprintf (current-output-port) "Opcode-Id:")
      				(pretty-display (send machine get-opcode-name opcode-id))
              (unless 
               (equal? opcode-id (get-field nop-id machine))
               (let* ([arg-ranges 
                       (send machine get-arg-ranges opcode-id #f live-in 
                             #:live-out live-out #:mode mode)])
                 (when arg-ranges
                       (enumerate opcode-id (vector->list arg-ranges)))
                 )))
         (yield (list #f #f #f))))
      iterator)

    ))
