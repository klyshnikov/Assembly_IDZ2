.data
one: .double 1
ten: .double 10
zr : .double 0
m_one : .double -1
percents: .double 0.05
test_1: .double 0.32
msg1: .asciz "\nEnter x - between -1 and 1: "
msg2: .asciz "\nError! Wrong array size!"
msg3: .asciz "\nCurrent value: 1/(1-x) ~= "
msg4: .asciz "\n== Testcase =="

.macro testcase

	li a7, 4
	la a0, msg4
	ecall
	
	fld ft0, percents, t0             # Get precents from data
	addi sp, sp, -4				# Count epsilon
	fsd ft0, (sp)				# Store percent data
	jal create_epsilon			# ft0 - actual parametr (percents)
	fmv.d fs1, fa0				# Move result to fs1

	fld fs0, test_1, t0
	
	fld ft10, zr, t0		  # Read 0 to ft10
	addi sp, sp, -4				# Check x
	fsd fs0, (sp)				# fa0 - actual parametr (x)
	jal check_x
	fgt.d t0, fa0, ft10               # Check answer, if it return 0, call ERROR 
	beqz t0, ERROR_SIZE

	li a7, 4                          # Enter answer message
	la a0, msg3
	ecall

	addi sp, sp, -4                         # Count answer
	fsd fs0, (sp)                           # fs0, fs1 - actual parametrs (x, epsilon)
	addi sp, sp, -4
	fsd fs1, (sp)
	jal count

	li a7, 3			 	# Result just in fa0 - show it;
	ecall
	
.end_macro
	
.text
fld ft0, percents, t0             # Get precents from data
addi sp, sp, -4				# Count epsilon
fsd ft0, (sp)				# Store percent data
jal create_epsilon			# ft0 - actual parametr (percents)
fmv.d fs1, fa0				# Move result to fs1

li a7, 4                      	  # Enter a welcome message
la a0, msg1
ecall

addi sp, sp, -4			        # Let user enter x
jal enter_x			        # No actual parametr
fmv.d fs0, fa0 			  	# Move result to fs0
fld ft10, zr, t0		  # Read 0 to ft10
addi sp, sp, -4				# Check x
fsd fa0, (sp)				# fa0 - actual parametr (x)
jal check_x
fgt.d t0, fa0, ft10               # Check answer, if it return 0, call ERROR 
beqz t0, ERROR_SIZE

li a7, 4                          # Enter answer message
la a0, msg3
ecall

addi sp, sp, -4                         # Count answer
fsd fs0, (sp)                           # fs0, fs1 - actual parametrs (x, epsilon)
addi sp, sp, -4
fsd fs1, (sp)
jal count

li a7, 3			 	# Result just in fa0 - show it;
ecall

testcase                          # Call test case

j end_program

.text 
enter_x:                 #void enter_x(double x)
	# Without registers
	addi sp, sp, -4              # Enter x from keyboard
	sw ra, (sp)

	li a7, 7
	ecall
	
	lw ra, (sp)
	ret
	
.text
check_x:                #bool check_x(double x)
	# ft0 = x
	# ft1 = res1 
	# ft2 = -1
	# ft3 = 1
	# ft4 = res2
	# ft10 = 0
	addi sp, sp, -16                   # Shift down to remember RA
	sw ra, (sp)
	addi sp, sp, 16
	fld ft0, (sp)
	addi sp, sp, -4
	
	
	fld ft3, one, t0                   # Write values to registers
	fld ft10, zr, t0
	fmv.d ft2, ft10
	fsub.d ft2, ft2, ft3
	
	fsd ft0, (sp)                      # Local vars
	addi sp, sp, -4
	fsd ft2, (sp)
	addi sp, sp, -4
	fsd ft3, (sp)
	addi sp, sp, -4
	
	fgt.d t0, ft0, ft2                 # Check value x
	fgt.d t1, ft3, ft0
	
	fmv.d fa0, ft10                    # If t0 = 1 and t1 = 1, fa0 = 1, and return 1
	bgtz t0, cond1                     # Else fa0 = 0, and return 0
	j no_cond
	
	cond1:
		bgtz t1, cond2
		j no_cond
	cond2:
		fmv.d fa0, ft3
		
	no_cond:
	
	lw ra, (sp)                        # Return
	ret
	
	
.text
create_epsilon:  	# double create_epsilon(double percents)
	# ft0 - percents
	# ft1 = 10
	# ft2 = 1
	addi sp, sp, -4           # This function get percents and return pers./100 = epsilon
	sw ra, (sp)

	addi sp, sp, 4             # Write values
	fld ft0, (sp)
	addi sp, sp, -4
	fld ft1, ten, t0
	fld ft2 one, t0
	fdiv.d ft0, ft0, ft1          # Count
	fdiv.d ft0, ft0, ft1
	fadd.d ft0, ft0, ft2
	fmv.d fa0, ft0

	lw ra, (sp)                    # Return 
	ret
	
.text
count:   		#double count(double x, double epsilon)
	# ft0 = x
	# ft1 = epsilon
	# ft3 = sum_prev
	# ft4 = sum_current
	# ft5 = sum_current/sum_prev
	# ft6 = x^(current_div)
	# ft7 = epsilon-1
	# ft8 = 1
	
	addi sp, sp, -20          # Shift to remember RA
	sw ra, (sp)
	
	addi sp, sp, 20            # Get parametrs
	fld ft1, (sp)
	addi sp, sp, 4
	fld ft0, (sp)
	addi sp, sp, -8
	
	fld ft3, one, t0               # Write some values
	fld ft6, one, t0
	fld ft8, one, t0
	fadd.d ft7, ft8, ft8
	fsub.d ft7, ft7, ft1
	
	fsd ft0, (sp)                    # Local vars
	addi sp, sp, -4
	fsd ft1, (sp)
	addi sp, sp, -4
	fsd ft7, (sp)
	addi sp, sp, -4
	fsd ft8, (sp)
	addi sp, sp, -4
	
	
	loop:                               # While current/previos not in range - count
		fmul.d ft6, ft6, ft0
		fmv.d ft4, ft3
		fadd.d ft4, ft4, ft6
		fdiv.d ft5, ft4, ft3
		fmv.d ft3, ft4
		flt.d t0, ft5, ft1
		fgt.d t1, ft5, ft7
		mul t0, t0, t1
		
		beqz t0, loop
		
	fmv.d fa0, ft4
	lw ra, (sp)                      # Return 
	ret

	
.text
ERROR_SIZE:           # If x not in (-1, 1)
li a7, 4
la a0, msg2
ecall
end_program:          # Jump here to end program

