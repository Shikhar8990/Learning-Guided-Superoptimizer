	eor	r3, r1, r0
	and	r0, r1, r0
	add	r0, r0, r3, asr #1    
  addcc r0, r1, r2, lsr #3
  tst r1, #3 
