# Daniel Spilchuk

.data	

.text
	main:	
		# Special MMIO addresses within kernel memory
		# DO NOT USE SYSCALLS FOR I/O except for v0, 10 for termination

		li $s0, 0xffff0000		# input control address
		li $s1, 0xffff0004		# input data address
		li $s2, 0xffff0008		# output control address
		li $s3, 0xffff000c		# output data address
		
		li $s6, 0			# first integer input
		li $s7, 0 			# second integer input
	
	
	# used for getting the first integer input
	ILoop:
		# gets input status, if 0 loop, otherwise input char into $t0
		lw $t0, 0($s0)
		beqz $t0, ILoop
		lb $t0, 0($s1)
		move $s6, $t0

	OLoop:
		# used to output the character given to the console, an echo
		lw $t1, 0($s2)
		beqz $t1, OLoop
		sb $t0, 0($s3)
	
	# used for getting the second integer input
	secondILoop:
		# gets input status, if 0 loop, otherwise input char into $t0
		lw $t0, 0($s0)
		beqz $t0, secondILoop
		lb $t0, 0($s1)
		move $s7, $t0
	secondOLoop:
		# used to output the character given to the console, an echo
		lw $t1, 0($s2)
		beqz $t1, secondOLoop
		sb $t0, 0($s3)

	

	# at this point in the program we have the cipher info
	# after the newLineLoop, multiply tens position by 10 and add ones position
	# $s6- the ascii value tens position in the movement of the cipher 
	# $s7- the ascii value ones position in the movement of the cipher
	
	newLineLoop:
		# print a newline to the console
		la $t0, '\n'
		lw $t1, 0($s2)
		beqz $t1, newLineLoop
		sb $t0, 0($s3)
		
			
		# subtract the s6(10's) ascii to 0 then multiply by 10 stored by t2
		# then add s7(1's) subtracted ascii code 
		# the remaining value is the code that i can add to letters ascii code
		li $t2, 10
		addi $s6, $s6, -48
		addi $s7, $s7, -48
		
		mul $s6, $s6, $t2 
		add $s6, $s6, $s7
	
	
	# now we need to implement the cipher and add the cypher to the ascii code
	# $s6- the cipher info to change ascii values by
	
	cipherInputLoop:
		#gets input status, if 0 loop, otherwise input char into $t0
		lw $t0, 0($s0)
		beqz $t0, cipherInputLoop
		lb $t0, 0($s1)
		
		# branch to terminate program if newline is given
		beq $t0, '\n', term
		
		# branch if ascii value is not between 98-123
		li $t2, 98
		li $t3, 123		
		ble $t0, $t2, cipherOutputLoop
		bge $t0, $t3, cipherOutputLoop
		
		# initializes the counter and limit for the wrap around and add loop 
		li $t2, 0
		li $t3, 122
		
		
	# at this point in the program the cipher
	# t0- the letter to be printed
	# t2- the counter to match the a6
	# t3- the limit at which z is reached and wrap around must occur
	# s6- the amount of ascii units to increase by
	cipherAddLoop:
		
		# if the counter is reached then output the character
		beq $t2, $s6, cipherOutputLoop
		addi $t2, $t2, 1
		
		# cipher wrap around if hit 'z'
		beq $t0, $t3, cipherWrapAround
		
		addi $t0, $t0, 1
		j cipherAddLoop
		
	cipherWrapAround:
		
		# if the ascii value reaches 123
		addi $t0, $t0, -25
		j cipherAddLoop
	
	
	cipherOutputLoop:
		# used to output the character given to the console, an echo
		# need to change the ascii values before each character is printed
		# using the cipher
		
		lw $t1, 0($s2)
		beqz $t1, cipherOutputLoop
		sb $t0, 0($s3)
	
		j cipherInputLoop
	
	
	# terminate program
	term:		
		li $v0, 10
		syscall