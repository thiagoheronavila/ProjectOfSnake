################################################################################
#			SNAKE`S GAME					       #
#	Names: Gregory Sedrez, Thiago Heron Avila                              # 
#------------------------------------------------------------------------------#
#			Settings of Bitmap Display:                            #
#		  Unit Width: 4       Display Width: 512                       #
#		  Unit Height: 4      Display Height: 256		       #
#------------------------------------------------------------------------------#		  	
#			 Others informations:				       #						  	
# (+4)BorderTop Pixels:     0 - 508 / 512 - 1020 / 1024 - 1532                 #
# (+4)BorderBottom Pixels:  31232 - 31740 /  31744 - 32252 / 32256 - 32764     #	
# (+512)BorderLeft Pixels:  0- 32256 / 4 - 32260			       #	
# (+512)BorderRight Pixels: 504- 32760 / 508 - 32764	                       #
#									       #
#------------------------------------------------------------------------------#
#			 Registers:					      	
#  T0 - Count				
#  T1 - Position where Snake Born(13060)
#  T2 - Position temporary to calculate a collision	
#  T3 - Pixel to calculate symbolic position, not is address: 512, -512, 4, -4
#  T4 - Store valeus which 512, -512, 4, -4 to return the keypress function.
#  T5 - Store values of border left or right
#  T8 = 1
#  T9 - SLTI			       
#  20 - Black				       	
#  21 - White				       				
#  22 - Gray							       	
#  23 - D. Red 
#------------------------------------------------------------------------------#
#			Call the Functions				       #								       
.text
	jal setColors
	nop

	jal defineSettings
	nop

	jal defineMap
	nop

	jal createSnake
	nop

	j readKeyPress	# We don't use jal because will need to call other function.
	nop


#-----------------------------------------------------------------------------#
#			Function to set the colors			      #	
setColors:
	addi $20, $0, 0x696969 # Black
	addi $21, $0, 0xFFFFFF # White
	addi $22, $0, 0xbfbfbf # Gray
	addi $23, $0, 0x8B0000 # Dark Red
	jr $31 
	nop
#------------------------------------------------------------------------------#
#		Function to define the Settings of Backgrund and Snake	       #
defineSettings:
	addi $9, $0, 8122  # (512x256) / (4x4)
	add $10, $0, $9    # Pixels to map
	lui $10, 0x1001
	addi $t1, $10, 13060 
	addi $t3, $0, 13060
	jr $31
	nop	

#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#
#			Function to define de Background		       #	
defineMap:
	beq $t0, 31224, endDefineMap
	nop
		sw $22, 0($10)
		addi $10, $10, 4  # Address +=4;
		addi $t0, $t0, 4  # Count +=4;
		j defineMap
		nop
endDefineMap:
	lui $10, 0x1001	# Reset Address
	move $t0, $0 	# Reset Count of defineMap	

#------------------------------------------------------------------------------#
defineBorderTop:
	beq $t0, 1536, endDefineBorderTop
	nop
		sw $23, 0($10)
		addi $10, $10, 4  # Address +=4;
		addi $t0, $t0, 4  # Count +=4;
		j defineBorderTop
		nop
endDefineBorderTop:
	lui $10, 0x1001	# Reset Address
	move $t0, $0 	# Reset Count of defineMap	
#------------------------------------------------------------------------------#
defineBorderBottom:
	beq $t0, 1536, endDefineBorderBottom
	nop
		sw $23, 31232($10)
		addi $10, $10, 4  # Address +=4;
		addi $t0, $t0, 4  # Count +=4;
		j defineBorderBottom
		nop
endDefineBorderBottom:
	lui $10, 0x1001	# Reset Address
	move $t0, $0 	# Reset Count of defineMap	
#------------------------------------------------------------------------------#
defineBorderLeft:
	beq $t0, 129, endDefineBorderLeft #(64 rows + 64 rows + 1)
	nop
		sw $23, 0($10)
		sw $23, 4($10)
		addi $10, $10, 512 # Address +512;
		addi $t0, $t0, 1
		j defineBorderLeft
		nop
endDefineBorderLeft:
	lui $10, 0x1001	# Reset Address
	move $t0, $0 	# Reset Count of defineMap
#------------------------------------------------------------------------------#
defineBorderRight:
	beq $t0, 129, endDefineBorderRight #(64 rows + 64 rows + 1)
	nop
		sw $23, 504($10)
		sw $23, 508($10)
		addi $10, $10, 512 # Address +512;
		addi $t0, $t0, 1
		j defineBorderRight
		nop
endDefineBorderRight:
	lui $10, 0x1001	# Reset Address
	move $t0, $0 	# Reset Count of defineMap
#------------------------------------------------------------------------------#
jr $31 	# End defineMap
nop
#------------------------------------------------------------------------------#
#------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#			Function to create the Snake			      #		
createSnake:
	
	sw $21, 13060($10)
	#beq $t0, 7, endCreateSnake
	#nop
		#sw $21, 13060($10)
		#addi $10, $10, 512
		#addi $t0, $t0, 1
		#j createSnake
		#nop
#endCreateSnake:
	#lui $10, 0x1001	# Reset Address
	#move $t0, $0 	# Reset Count of defineMap	
	jr $31
	nop
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#	 Function to Control the Snake: W,A,S,D or 0 to Exit		      #		  		
readKeyPress:	

	li $v0, 12			# Read a Caracter: W,A,S,D or 0  to Exit
	syscall	

	beq $v0, 119, pressKeyW 	# W - LowerCase
	nop		
	beq $v0, 82, pressKeyW		# W - UpperCase
	nop
	beq $v0, 115, pressKeyS		# S - LowerCase
	nop
	beq $v0, 83, pressKeyS		# S - UpperCase
	nop
	beq $v0, 97, pressKeyA		# A - LowerCase
	nop
	beq $v0, 65, pressKeyA		# A - UpperCase
	nop,
	beq $v0, 100, pressKeyD		# D - LowerCase
	nop
	beq $v0, 68, pressKeyD		# D - UpperCase
	nop


	beq $v0, 48, gameOver		# 0 - Exit
	nop
	j readKeyPress
	nop
#-----------------------------------------------------------------------------#
pressKeyW:
	addi $t3, $t3, -512
	addi $t4, $0, -512

	j checkBorderCollision
	nop	


W:	sw $22, 0($t1)	   # Print pixel to grey
	addi $t1, $t1, -512  # Position snake up
	sw $21, 0($t1)	   # Print pixel to white
	j readKeyPress
	nop
#-----------------------------------------------------------------------------#
pressKeyS:
	addi $t3, $t3, 512
	addi $t4, $0, 512

	j checkBorderCollision
	nop

S:	sw $22, 0($t1)	   # Print pixel to grey
	addi $t1, $t1,  512 # Position snake down
	sw $21, 0($t1)	   # Print pixel to white
	j readKeyPress
	nop
#-----------------------------------------------------------------------------#
pressKeyA:
	addi $t3, $t3, -4
	addi $t4, $0, -4

	j checkBorderCollision
	nop

A:	sw $22, 0($t1)	   # Print pixel to grey
	addi $t1, $t1, -4  # Position snake up
	sw $21, 0($t1)	   # Print pixel to white
	j readKeyPress
	nop
#-----------------------------------------------------------------------------#
pressKeyD:
	addi $t3, $t3, 4
	addi $t4, $0, 4

	j checkBorderCollision
	nop

D:	sw $22, 0($t1)	   # Print pixel to grey
	addi $t1, $t1, 4  # Position snake up
	sw $21, 0($t1)	   # Print pixel to white
	j readKeyPress
	nop
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
#		Function to check collision with the borders		      #	

checkBorderCollision:
	addi $t8, $0, 1
	
	# Check Border Top
	slti $t9, $t3, 1541	# If previous position < 151 = Red Field, gameOver
	beq $t9, $t8, gameOver
	nop
	
	# Check Border Bottom
	slti $t9, $t3, 31221	# If previous position < 31220 = Red Field, gamOver
	beq $t9, $0, gameOver
	nop
	
	# Check Border Left
	addi $t5, $0, 1540
	
BL:	beq $t5, 31236, checkRight
	nop
		beq $t3, $t5, gameOver	# If t3 is equal to a one value of borderLeft
		nop
		addi $t5, $t5, 512
		j BL
		nop

checkRight:
	addi $t5, $0, 1528

BR:	beq $t5, 31736, continue
	nop
		beq $t3, $t5, gameOver
		nop
		addi $t5, $t5, 512
		j BR
		nop

continue:

	beq $t4, -512, W
	nop
	beq $t4, 512, S
	nop
	beq $t4, 4, D
	nop
	beq $t4, -4, A
	nop
	
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#	

		
#-----------------------------------------------------------------------------#
#		Function to create the Game Over Screen			      #

gameOver:
beq $t0, 32764, endgameOver
	nop
		sw $20, 0($10)
		addi $10, $10, 4  # Address +=4;
		addi $t0, $t0, 4  # Count +=4;
		j gameOver
		nop
endgameOver:
	li $v0, 10
	syscall
#-----------------------------------------------------------------------------#
#-----------------------------------------------------------------------------#