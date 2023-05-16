#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Bao Yang, 1008073371, yangbao1, bao.yang@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 
# - Unit height in pixels: 8 
# - Display width in pixels: 512 
# - Display height in pixels: 512 
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 3
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Double Jump
# 2. Start Menu
# 3. Health
# 4. Fail Condition
# 5. Moving Objects
# 6. Win Condition
# 7. Disappearing Platforms
# 
# Link to video demonstration for final submission:
# - 
#
# Are you OK with us sharing the video with people outside course staff?
# - yes
#
# Any additional information that the TA needs to know:s
# - Movement while jumping works alot smoother if your keyboard repeat delay is shorter
######################################################################
.data
## Collision areas
headcol: .word 47 55 44, 23 32 30, 1 16 3, 32 44 15, 0 28 47, 0 60 55 #Stores area you cant go up as: x1 x2 y
feetcol: .word 47 55 50, 23 32 36, 1 16 9, 32 44 21, 0 60 0 #Stores area you cant go down as: x1 x2 y 
leftcol: .word 44 50 56, 30 36 33, 3 9 17, 15 21 45 , 47 60 29, 0 55 0#Stores area you cant go left as: y1 y2 x
rightcol: .word 44 50 46, 30 36 22, 3 9 0, 15 21 31,  0 55 60 #Stores area you cant go right as: y1 y2 x
## Enemie areas
spike: .word 9 16 9 #stores area of spike (x1, x2, y)
fire: .word 37 44 21 #stores area of fire
##  Coins (Stationary)
coin1: 0x1000B704
coin2: 0x10008A28
##Disappearing platforms:
dp1: .word 0
dp2: .word 0
## Moving objects
mc: .word  0x100089F0  11 	#Moving coin [top left corner of coin, 0-10 go down 11-20 go up]
ms: .word 0x1000B13C 8		#Moving spike
## Character stats
health:  .word 3
collectedcoins: .word 0
time: .word 0

## Constants
.eqv BASE_ADDRESS 0x10008000
.eqv BG_COLOR 0xE0D8D7
.eqv HURT_COLOR 0xF5F5F5
.eqv CHAR_COLOR 0x802924

.text
### Main menu
start:	li $a2 0x000000			# Clear the screen
		li $a0 BASE_ADDRESS
		add $a1, $a0, 16380
		jal draw
		li $s0, 0						#s0 = selcted (1,2)
		#Draw menu
		jal menu
		li $t1, 0xffffff				#Unselcted color
		jal but1
		jal but2
		
startloop:	#Get Button press
		li $t9, 0xffff0000 		
		lw $t8, 0($t9)
		beq $t8, 0, startloop
		#When key is pressed
 		lw $t2, 4($t9) 				#t2 = pressed key
 		li $t1, 0xd92e72
		beq $t2, 97, selected1
		beq $t2, 100, selected2 
		beq $t2, 32, space
		j startloop		
selected1:	li $s0 1					#Selected START
		jal but1
		li $t1, 0xffffff
		jal but2
		j startloop
selected2: 	li $s0 2					#Selected EXIT
		jal but2
		li $t1, 0xffffff
		jal but1
		j startloop
space:	beq $s0, 2, exit				#Go to selected option
		beq $s0, 1, main
		j startloop
		
#Main program	
main: 	li $s0, 14200			# s0 = Upper left corner of charcter location
		li $s1, 30				# s1 = x cord of character
		li $s2, 0					# s2 = y cord of character
		li $s7, CHAR_COLOR	#s7 = character color
		
		li, $t2, 3				#Initalize data
		sw $t2, health			#
		li, $t2, 0				#
		sw $t2, collectedcoins	#
		sw $t2, time 			#
		sw $t2, dp1			#
		sw $t2, dp2			#
		li $t2, 0x1000B704		#
		sw $t2, coin1			#
		li $t2, 0x10008A28		#
		sw $t2, coin2			#
		li $t2, 0x100089F0		#
		sw $t2, mc				#
		li $t2, 11				#
		sw $t2, mc+4			#
		li $t1, 44
		sw $t1,  headcol+8
		li $t1, 50
		sw $t1, feetcol+8
		li $t1, 56
		sw $t1, leftcol+8
		li $t1, 46
		sw $t1, rightcol+8
		li $t1, 30
		sw $t1,  headcol+20
		li $t1, 36
		sw $t1, feetcol+20
		li $t1, 33
		sw $t1, leftcol+20
		li $t1, 22
		sw $t1, rightcol+20
		
		jal level					#Draw everything
		jal dspike				#
		jal dfire					#
		jal char					#
		li $t1, 0xff0f0f			#
		jal heart1				#
		jal heart2				#
		jal heart3				#
		lw $a0, mc				#
		jal dcoin				#	
		lw $a0, coin1			#
		jal dcoin				#
		lw $a0, coin2			#
		jal dcoin				#
		
mainloop:	li $t9, 0xffff0000	 	# Get keypress
			lw $t8, 0($t9)
			jal dspike				# Redraws enemies
			jal dfire
			lw $t0, time			#Animate moving Objects
			addi, $t0, $t0, 1		#
			sw $t0, time			#
			li $t1, 2000				#
			div  $t0, $t1			#
			mfhi $a3				#
			jal mspike				#
			jal mcoin				#
			lw $t0, time			#Disappearing platform1
			li $t1, 50000			#
			div  $t0, $t1			#
			la $a0, dp1				#
			li $a1, 2760				#
			li $a2, 2780				#
			li $a3, 8					#
			jal dplat				#
			lw $t0, time			#Disappearing platform2
			li $t1, 85120			#
			div  $t0, $t1			#
			la $a0, dp2				#
			li $a1, 6248				#
			li $a2, 6272				#
			li $a3, 20				#
			jal dplat				#
			
							
			beq $t8, 0, mainloop	#Nothing pressed
			
			#when key is pressed
 			lw $t2, 4($t9) 			#t2 = pressed key
	 		la, $a0, mainfall		
			beq $t2, 97, left
			beq $t2, 100, right 
			beq $t2, 112, main 
			beq $t2, 119, jump
			jal char
mainfall:	j fall
checkhurt:	la $a0, spike		#Check if hurt by spike
			jal hurt
			jal dspike
			la $a0, fire				#Check if hurt by fire
			jal hurt
			jal dfire 
			jal checkcoin		#Check if coin was collected
			j mainloop

#Ends the program
exit: 		li $v0, 10
			syscall
		
###################################
###  COINS  ###	
checkcoin:	move $s4, $ra
			la $a0, coin1						#Check if collected coin1
			jal coin
			la $a0, coin2						#Check if collected coin2
			jal coin
			la $a0, mc							#Check if collected moving
			jal coin
			move $ra, $s4
			jr $ra
		
coin: 		move $s3, $ra
			lw $t0, ($a0)							#t0 = location of coin
			beqz $t0, creturn					#return if already collected
			li $t2, 0
			addi $t1, $s0, BASE_ADDRESS		#t1 = location of char
			addi, $t0, $t0, -12					#first row of coin
			move $t3, $t0
			beq $t1, $t0, collected	
coinloop1:	addi, $t0, $t0, 4
			beq $t1, $t0, collected
			addi $t2, $t2, 1
			bne $t2, 5, coinloop1
			addi, $t0, $t3, 256
			li $t2, 0
coinloop2:	addi, $t0, $t0, 4
			beq $t1, $t0, collected
			addi $t2, $t2, 1
			bne $t2, 6, coinloop2
			addi, $t0, $t3, 256
			li $t2, 0
coinloop3:	addi, $t0, $t0, 4
			beq $t1, $t0, collected
			addi $t2, $t2, 1
			bne $t2, 6, coinloop3
			j creturn
collected:	li $t2, BG_COLOR					#Erase coin
			lw $t0, ($a0)
			sw $t2, 0($t0)						
	        	sw $t2, 4($t0)
        		sw $t2, 8($t0)
        		sw $t2, 256($t0)
	        	sw $t2, 260($t0)
        		sw $t2, 264($t0)
        		sw $t2, 512($t0)
  		      	sw $t2, 516($t0)
        		sw $t2, 520($t0)					
			li $t0, 0								#update coin to collected
			sw $t0, ($a0)
			li $s7, 0xffe066						#Make char color flash
			jal char
			li $a1, 150
			jal delay
			li $s7, CHAR_COLOR
			jal char			
			
			lw $t0, collectedcoins				# Increment collected coins
			addi $t0, $t0, 1
			sw $t0, collectedcoins						
			beq $t0, 3, win						#When cloocked coins =3, win
creturn:	move $ra, $s3						# Return
			jr $ra
###################################

###################################
### CHARACTER MOVEMENT ###	
### left(a0 = return address)
### Draws the character one unit to the left
left:	# save ra
	move $s3, $a0		#s3 = ra
	# Check if out of bounds NEED TO UPDATE
	bgt $s1, 0, lstart
	jr $s3
lstart:	# Erase old char	
	addi $t0, $s0, BASE_ADDRESS
	add $t0, $t0, 12
	li $t1, BG_COLOR
	sw $t1, ($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	# update cordinate
	addi, $s1, $s1, -1
	# Move char to left
	addi $s0, $s0, -4	
	jal char
	# Draw face
	li $t6, BG_COLOR
	addi $t0, $s0, BASE_ADDRESS
	sw $t6, 256($t0)
	#reload ra
	move $ra, $s3
	jr $ra

### right(a0 = return address)
### Draws the character one unit to the right	
right: 	# save ra
	move $s3, $a0
	#Check if out of bounds
	# save ra
	move $s3, $a0		#s3 = ra
	# Check if out of bounds NEED TO UPDATE
	blt $s1, 60, rstart
	jr $s3
	# Erase old char	
rstart:	addi $t0, $s0, BASE_ADDRESS
	li $t1, BG_COLOR
	sw $t1, ($t0)
	sw $t1, 256($t0)
	sw $t1, 512($t0)
	sw $t1, 768($t0)
	sw $t1, 1024($t0)
	# update cordinate
	addi, $s1, $s1, 1
	# Move char to left
	addi $s0, $s0, 4	
	jal char
	# Draw face
	li $t6, BG_COLOR
	addi $t0, $s0, BASE_ADDRESS
	sw $t6, 268($t0)
	#reload ra
	move $ra, $s3
	jr $ra
	
### jump() 
### Moves the character 15 units up, then falls
jump: 	li, $s6, 0		#counter for double jump
jump1:	addi $s5, $s2, 13
jloop:	#Check if char is at head collision point
	la $a0, headcol
	li $a1, 0
	li $a2, 6
	jal col
	bne $v0, 1 jmove	# if not colliding, go up 1 unit
	j fall
##Movement while jumping
jmove:	jal dspike
	jal dfire
	#check if want to move left/right while jumping
	li $t9, 0xffff0000 	#Checks if key is pressed
	lw $t8, 0($t9)
	beq $t8, 0, jstart
	#when key is pressed
 	lw $t2, 4($t9) 		#t2 = pressed key
 	la, $a0, jstart
	beq $t2, 97, jL
	beq $t2, 100, jR
	bnez, $s6, jstart
	beq $t2, 119, jD
	j jstart
jL:	la $a0, leftcol		#check if char is at left collision
	li $a1, 1
	li $a2, 6
	jal col
	bne $v0, 0 jstart
	la, $a0, jstart
	j left			#Moves left while jumping
jR:	la $a0, rightcol	#check if char is at right collision
	li $a1, 1
	li $a2, 5
	jal col
	bne $v0, 0 jstart
	la, $a0, jstart
	j right			#Moves right while jumping
jD: 	li $s6, 1		#Double jumps ONLY ALLOWED ONCE
	#delay
	li $a1, 30
	jal delay
	j jump1

jstart:
	addi $s0, $s0, -256	#jump 1 unit	
	jal char
	#erase feet
	addi $a0, $s0, BASE_ADDRESS
	addi $a0, $a0, 1280
	addi $a1, $a0, 12
	li $a2, BG_COLOR
	jal draw
	#add 1 unit to y 
	addi $s2, $s2, 1
	jal checkcoin
	#delay
	li $a1, 30
	jal delay
	
	#keep rising until 
	bne $s2,  $s5, jloop

### fall()
### Moves the character 1 unit down until it hits feet colision area
fall:	#Check if char is at a feet col point
	la $a0, feetcol
	li $a1, 0
	li $a2, 5
	jal col
	bne $v0, 1 fmove	
	j checkhurt		#char on platform, stop falling
	
fmove:	#check if want to move left/right while falling
	li $t9, 0xffff0000 	#Checks if key is pressed
	lw $t8, 0($t9)
	beq $t8, 0, fstart
	#when key is pressed
 	lw $t2, 4($t9) 		#t2 = pressed key
	beq $t2, 97, fL
	beq $t2, 100, fR
	bnez, $s6, fstart
	beq $t2, 119, jD	##
	j fstart
fL:	la $a0, leftcol		#check if char is at left collision
	li $a1, 1
	li $a2, 6
	jal col
	bne $v0, 0 fstart
	la, $a0, fstart
	j left			# Move left
fR:	la $a0, rightcol	#check if char is at right collision
	li $a1, 1
	li $a2, 5
	jal col
	bne $v0, 0 fstart
	la, $a0, fstart
	la, $a0, fstart
	j right			# Move right
	
fstart:	
	jal checkcoin
	#erase forehead
	addi $a0, $s0, BASE_ADDRESS
	addi $a1, $a0, 12
	li $a2, BG_COLOR
	jal draw
	#draw character
	addi $s0, $s0, 256
	jal char
	#delay
	li $a1, 20
	jal delay
	#update y position 1 down
	addi, $s2, $s2, -1
	#Keep falling
	j fall

#delay(a1 = delay in millisecond)
delay: 	li $v0, 32
	move $a0, $a1
	syscall
	jr $ra
###################################

###################################
### HEALTH ###
# When char standing on hurtful object, lose a heart
# Make character white
hurt: move $s6, $ra		#save ra
	#check if char is on object
	li $a1, 0
	li $a2, 1
	jal col
	bne $v0, 1, hreturn	# if not hurt, return
	#IF HURT
	la $t0, health			#t0 = address of health
	lw, $t2, ($t0)			#t1 = health
	addi, $t2, $t2, -1		# --health
	blez $t2, lose			
	sw $t2, ($t0)
	li $t1, BG_COLOR		#ERASE HEART
	beq $t2, 2, h2
	beq $t2, 1, h1
	jal heart1
	j hcolor
h1:	jal heart2
	j hcolor
h2:	jal heart3
					
hcolor:	
	li $s7, BG_COLOR
	jal char
	li $s7, HURT_COLOR	# Change character color
	li $s0, 14200			# s0 = Upper left corner of charcter location
	li $s1, 30				# s1 = x cord of character
	li $s2, 0					# s2 = y cord of character
	jal char
	# Delay
	li $a1, 150
	jal delay
	# Draw healthy 
	li $s7, CHAR_COLOR
	jal char
	#return
hreturn:move $ra, $s6
	jr $ra
###################################

###################################
### COLLISIONS ###
### col(a0 = address of col[0], a1 = collision type, a2 = # items in array)
### type indicates the format of the array: 0 = x1 x2 y , 1 = y1 y2 x
### v0 = 1 if colision, v0 = 0 if none
col: 	li $t4, 1		#t4 = i (loop iterator)
cloop:	lw $t1, 0($a0)		#t1 = x1 = y1
	lw $t2, 4($a0)		#t2 = x2 = y2
	lw $t3, 8($a0)		#t3 = y  = x
	beq $a1, 1, type1
	#if s2 = y and s1 within <x1,x2> return 1
	bne $s2, $t3, citer
	blt $s1, $t1, citer
	bgt $s1, $t2, citer
	j ret1
	#if s1 = x and s2 within <y1,y2> return 1
type1:	bne $s1, $t3, citer
	blt $s2, $t1, citer
	bgt $s2, $t2, citer
ret1:	li $v0, 1
 	jr $ra
citer:	beq, $t4, $a2, ret0	#iterate through entire array
	addi, $t4, $t4, 1
	addi $a0, $a0, 12	
	j cloop
ret0:	li $v0, 0		#Return 0 if no colision
	jr $ra
###################################

###################################
### DRAWING ###
level: 	move $t7, $ra
	li $t0, BASE_ADDRESS 	# $t0 stores the base address for display
	#Draw background
	li $a0, BASE_ADDRESS	# $a0 = address of start of bg
	addi $a1, $t0, 15356	# $a1 =  address of end of bg
	li $a2, BG_COLOR 	# $a2 = bg color
	jal draw			# call draw()
	#Draw floor
	addi, $a1, $t0, 16380	# $a1 = address of end of grass
	li, $a2, 0xA26763 	# $a2 = floor color
	jal draw			# call draw()
	#Draw platform1
	addi, $a0, $t0, 13072	# $a0 = address of start of platform1
	addi, $a1, $t0, 13120	# $a1 = address of end of platform1
	li, $a2, 0xD8928E 	# $a2 = platform color
	jal draw			# call draw()
	#Draw platform2
	addi, $a0, $t0, 2760	# $a0 = address of start of platform2
	addi, $a1, $t0, 2780	# $a1 = address of end of platform2
	jal draw			# call draw()
	#Draw platform3
	addi, $a0, $t0, 10124	# $a0 = address of start of platform3
	addi, $a1, $t0, 10160	# $a1 = address of end of platform3
	jal draw			# call draw()
	#Draw platform4
	addi, $a0, $t0, 6248	# $a0 = address of start of platform4
	addi, $a1, $t0, 6272	# $a1 = address of end of platform4
	jal draw
	move $ra, $t7			
	jr $ra
	
### DRAW OBJECTS
#Draw spike 
dspike: 	li $t1, 0x898989   	# t1 = spike color
		li $t2, 0xffffff
		lw $t0, ms			#t0 = start of spike
		sw $t1, 0($t0) 		
		sw $t1, -8($t0) 	
		addi, $t0, $t0, 260	
		sw $t1, 0($t0) 
		sw $t2, -4($t0) 			
		sw $t1, -8($t0) 		
		sw $t2, -12($t0) 	
		sw $t1, -16($t0)
		jr $ra	
#Draw  fire
dfire:	li $t1, 0xfe0000 #t1 = red
		li $t2, 0xff7e00	#t2 = orange
		li $t3, 0xffcc00	#t3 = yellow
		li $t0, BASE_ADDRESS
		addi, $t4, $t0, 9380	
		sw $t1, 0($t4) 		
		sw $t1, 8($t4) 		
		addi, $t4, $t0, 9636	
		sw $t1, 0($t4) 		
		sw $t2, 4($t4) 		
		sw $t1, 8($t4) 		
		addi, $t4, $t0, 9888	
		sw $t1, 0($t4) 		
		sw $t2, 4($t4) 		
		sw $t3, 8($t4) 		
		sw $t2, 12($t4) 	
		sw $t1, 16($t4)
		jr $ra
#Draw coin
#dcoin (a0 = top left corner of coin)
dcoin: 	li $t1, 0xf0f9b6
        	li $t2, 0xfdf339
        	li $t3, 0xf0c33b
        	li $t4, 0xf8fb4a
        	li $t5, 0xfdc148
        	li $t6, 0xef9656
        	sw $t1, 0($a0)
        	sw $t2, 4($a0)
        	sw $t3, 8($a0)
        	sw $t4, 256($a0)
        	sw $t5, 260($a0)
        	sw $t6, 264($a0)
        	sw $t2, 512($a0)
        	sw $t6, 516($a0)
        	sw $t6, 520($a0)
		jr $ra
###DRAW CHARACTER			
### char(a0 = character color) 
char:	li $t0, BASE_ADDRESS
	move $t1, $s7 		# t1 = main character color 
	li $t7, BG_COLOR	# t7 = bg color
	move $a3, $ra		# a3 = ra
	move $t2, $s0		# start of character
	move $t3, $t2		# t3 = where to draw
	# Draw line 1 of character
	add, $a0, $t0, $t3	
	addi, $t3, $t2, 12
	add, $a1, $t0, $t3	
	move, $a2, $t1	# set character color
	jal draw
	# Draw line 2 of character
	addi, $t3, $t2, 256
	add, $t3, $t0, $t3
	sw $t1, 0($t3)
	sw $t7, 4($t3) 
	sw $t7, 8($t3)  		
	sw $t1, 12($t3) 		
	# Draw line 3 of character
	addi, $t3, $t2, 512
	add, $t3, $t3, $t0
	sw $t1, 4($t3)
	sw $t1, 8($t3)
	sw $t1, 0($t3)
	sw $t1, 12($t3)
	# Draw line 4 of character
	addi, $t3, $t2, 768
	add, $a0, $t0, $t3	# $a0 = start of line 4
	addi, $t3, $t3, 12
	add, $a1, $t0, $t3	# $a1 = end of line 4
	jal draw	
	# Draw line 5 of character
	addi, $t3, $t2, 1024
	add, $t3, $t3, $t0	
	sw $t1, 0($t3) 	
	sw $t7, 4($t3) 
	sw $t7, 8($t3)	
	sw $t1, 12($t3)
	move $ra, $a3
	jr $ra		#Finished drawing character, return 
	
### draw(a0 = address of start, a1 = address of end, a2 = color)
### draws a straight line from a0 to a1 in the color of a2
draw: 	sw $a2, 0($a0) 		# paint the pixel
	addi $a0, $a0, 4 	# update to next pixel
	ble $a0, $a1, draw	# loop if didn't reach end
	jr $ra
###################################

###################################
### DISAPPEARING PLATFORMS ###
#dplat(a0 = dp1/dp2, a1 = start of plat, a2 = end of plat, a3 = collision address)
dplat:		move $s6, $ra
			mfhi $t0
			bnez $t0, dreturn		#return if not time to dissapear/reappear
			li $t0, BASE_ADDRESS
			lw $t5, ($a0)				
			move $s5, $a0
			bnez $t5, appear 

disappear:	add, $a0, $t0, $a1			#Erase platform
			add, $a1, $t0, $a2			
			li, $a2, BG_COLOR
			jal draw
			
			li $t1, -1					#Update collision data
			sw $t1, ($s5)
			la $t3, headcol
			add, $t3, $t3, $a3
			sw $t1, ($t3)
			la $t3, feetcol
			add, $t3, $t3, $a3
			sw $t1, ($t3)
			la $t3, leftcol
			add, $t3, $t3, $a3
			sw $t1, ($t3)
			la $t3, rightcol
			add, $t3, $t3, $a3
			sw $t1, ($t3)
			j fall
			j dreturn
appear:	add, $a0, $t0, $a1			#Erase platform
			add, $a1, $t0, $a2	
			li, $a2, 0xD8928E
			jal draw
			li $t1, 0
			sw $t1, ($s5)
			beq $a3, 20, appearp2
			sw $t1,  headcol+8			#update collision data of plat1
			li $t1, 50
			sw $t1, feetcol+8
			li $t1, 56
			sw $t1, leftcol+8
			li $t1, 46
			sw $t1, rightcol+8
			j dreturn
appearp2:	li $t1, 30					#update collision data of plat2
			sw $t1,  headcol+20
			li $t1, 36
			sw $t1, feetcol+20
			li $t1, 33
			sw $t1, leftcol+20
			li $t1, 22
			sw $t1, rightcol+20
	
dreturn:	move $ra, $s6
			jr $ra
###################################							

###################################
### MOVING OBJECTS  ###
#Move coin
mcoin: 		move $s6, $ra
			bnez $a3, return
			#up or down
			lw $t0, mc				#t0 = top right corner of coin
			beqz $t0, return
			lw $s4, mc+4			#s4 = up or down
			addi $s4, $s4, -1
			sw $s4, mc+4
			ble $s4, 10, mcdown
mcup: 		addi $a0, $t0, 512
			addi, $a1, $a0, 8
			li $a2, BG_COLOR
			jal draw
			addi, $t0, $t0, -256
			sw $t0, mc
			move $a0, $t0 
			jal dcoin
			j return
mcdown:	move $a0, $t0
			addi, $a1, $t0, 8
			li $a2, BG_COLOR
			jal draw
			addi, $t0, $t0, 256
			sw $t0, mc
			move $a0, $t0 
			jal dcoin	
			bnez $s4, return		
			li $t1, 22
			sw $t1, mc+4
return:		move $ra, $s6
			jr $ra
			
#Move spike spike: .word 9 16 9
mspike:		move $s5, $ra
			bnez $a3, msreturn 	#only draw in certain intervals of time
			#left or right
			lw $t0, ms				#t0 = top left corner of coin
			lw $s4, ms+4			#s4 = left or right
			addi $s4, $s4, -1		#Increment L/R
			sw $s4, ms+4
			li $t1, BG_COLOR
			sw $t1, -4($t0)
			sw $t1, 244($t0)
			sw $t1, -8($t0)
			sw $t1, ($t0)
			sw $t1, 260($t0)
			ble $s4, 7, msleft
msright: 	addi, $t0, $t0, 4
			sw $t0, ms
			la $t0, spike
			lw $t2, spike
			addi, $t2, $t2, 1
			sw $t2, ($t0)
			lw $t2, 4($t0)
			addi, $t2, $t2, 1
			sw $t2,  4($t0)
			jal dspike
			j msreturn
msleft:		addi, $t0, $t0, -4
			sw $t0, ms
			la $t0, spike
			lw $t2, spike
			addi, $t2, $t2, -1
			sw $t2, ($t0)
			lw $t2, 4($t0)
			addi, $t2, $t2, -1
			sw $t2,  4($t0)
			jal dspike	
			bnez $s4, msreturn		
			li $t1, 16
			sw $t1, ms+4
msreturn:	la $a0, spike		#Check if hurt by spike
			jal hurt
			move $ra, $s5
			jr $ra			
###################################

###################################
### LOSE/WIN  ###
### When player loses (Lost all hearts)
lose:		li $a2 0x000000		# Clear the screen
		li $a0 BASE_ADDRESS
		add $a1, $a0, 16380
		jal draw
		li $s0, 0		#s0 = selcted (1,2)
		#Draw screen
		jal defeat
		jal sussy
		li $t1, 0xffffff		#Unselcted color
		jal but3
		jal but4
		#Get Button press
loseloop:	li $t9, 0xffff0000 	#Checks if key is pressed
		lw $t8, 0($t9)
		beq $t8, 0, loseloop
		#when key is pressed
 		lw $t2, 4($t9) 		#t2 = pressed key
 		li $t1, 0xd92e72
		beq $t2, 97, s1
		beq $t2, 100, s2 
		beq $t2, 112, main
		beq $t2, 32, s3		#Spacebar
							
		j loseloop		
s1:		li $s0 1
		jal but3
		li $t1, 0xffffff
		jal but4
		j loseloop
s2: 		li $s0 2
		jal but4
		li $t1, 0xffffff
		jal but3
		j loseloop
s3:		beq $s0, 2, exit
		beq $s0, 1, start
		j loseloop
		
### When player wins (Collects all coins) 
win: 	li $a2 0x000000		# Clear the screen
		li $a0 BASE_ADDRESS
		add $a1, $a0, 16380
		jal draw
		li $s0, 0		#s0 = selcted (1,2)
		#Draw screen
		jal victory
		jal sussy
		li $t1, 0xffffff		#Unselcted color
		jal but3
		jal but4
		j loseloop
###################################

###################################
### IMAGES ###
menu:	la $t0, BASE_ADDRESS
        li $t1, 0xffffff
        li $t2, 0xe8a7c1
        li $t3, 0xc995aa
        li $t4, 0xebebeb
        sw $t1, 528($t0)
        sw $t1, 744($t0)
        sw $t1, 780($t0)
        sw $t1, 784($t0)
        sw $t1, 804($t0)
        sw $t1, 808($t0)
        sw $t1, 812($t0)
        sw $t1, 816($t0)
        sw $t1, 820($t0)
        sw $t1, 824($t0)
        sw $t1, 828($t0)
        sw $t1, 940($t0)
        sw $t1, 996($t0)
        sw $t1, 1000($t0)
        sw $t1, 1040($t0)
        sw $t1, 1060($t0)
        sw $t1, 1084($t0)
        sw $t1, 1088($t0)
        sw $t1, 1256($t0)
        sw $t1, 1312($t0)
        sw $t1, 1316($t0)
        sw $t1, 1344($t0)
        sw $t1, 1564($t0)
        sw $t1, 1568($t0)
        sw $t1, 1600($t0)
        sw $t1, 1820($t0)
        sw $t1, 1836($t0)
        sw $t1, 1840($t0)
        sw $t1, 1860($t0)
        sw $t1, 2072($t0)
        sw $t1, 2076($t0)
        sw $t1, 2088($t0)
        sw $t1, 2092($t0)
        sw $t1, 2096($t0)
        sw $t1, 2100($t0)
        sw $t1, 2116($t0)
        sw $t1, 2328($t0)
        sw $t1, 2344($t0)
        sw $t1, 2356($t0)
        sw $t1, 2372($t0)
        sw $t1, 2376($t0)
        sw $t1, 2380($t0)
        sw $t1, 2584($t0)
        sw $t1, 2596($t0)
        sw $t1, 2600($t0)
        sw $t1, 2612($t0)
        sw $t1, 2628($t0)
        sw $t1, 2636($t0)
        sw $t1, 2640($t0)
        sw $t1, 2836($t0)
        sw $t1, 2840($t0)
        sw $t1, 2852($t0)
        sw $t1, 2868($t0)
        sw $t1, 2884($t0)
        sw $t1, 2888($t0)
        sw $t1, 2896($t0)
        sw $t1, 3092($t0)
        sw $t1, 3108($t0)
        sw $t1, 3112($t0)
        sw $t1, 3116($t0)
        sw $t1, 3120($t0)
        sw $t1, 3124($t0)
        sw $t1, 3144($t0)
        sw $t1, 3152($t0)
        sw $t1, 3228($t0)
        sw $t1, 3348($t0)
        sw $t1, 3400($t0)
        sw $t1, 3408($t0)
        sw $t1, 3412($t0)
        sw $t1, 3432($t0)
        sw $t1, 3436($t0)
        sw $t1, 3452($t0)
        sw $t1, 3456($t0)
        sw $t1, 3460($t0)
        sw $t1, 3464($t0)
        sw $t1, 3500($t0)
        sw $t1, 3508($t0)
        sw $t1, 3512($t0)
        sw $t1, 3516($t0)
        sw $t1, 3520($t0)
        sw $t1, 3524($t0)
        sw $t1, 3540($t0)
        sw $t1, 3544($t0)
        sw $t1, 3548($t0)
        sw $t1, 3552($t0)
        sw $t1, 3584($t0)
        sw $t1, 3604($t0)
        sw $t1, 3656($t0)
        sw $t1, 3668($t0)
        sw $t1, 3684($t0)
        sw $t1, 3688($t0)
        sw $t1, 3692($t0)
        sw $t1, 3696($t0)
        sw $t1, 3708($t0)
        sw $t1, 3720($t0)
        sw $t1, 3724($t0)
        sw $t1, 3740($t0)
        sw $t1, 3756($t0)
        sw $t1, 3764($t0)
        sw $t1, 3780($t0)
        sw $t1, 3784($t0)
        sw $t1, 3796($t0)
        sw $t1, 3808($t0)
        sw $t1, 3812($t0)
        sw $t1, 3860($t0)
        sw $t1, 3912($t0)
        sw $t1, 3924($t0)
        sw $t1, 3936($t0)
        sw $t1, 3940($t0)
        sw $t1, 3960($t0)
        sw $t1, 3964($t0)
        sw $t1, 3980($t0)
        sw $t1, 3996($t0)
        sw $t1, 4012($t0)
        sw $t1, 4016($t0)
        sw $t1, 4020($t0)
        sw $t1, 4040($t0)
        sw $t1, 4052($t0)
        sw $t1, 4068($t0)
        sw $t1, 4072($t0)
        sw $t1, 4116($t0)
        sw $t1, 4168($t0)
        sw $t1, 4176($t0)
        sw $t1, 4180($t0)
        sw $t1, 4192($t0)
        sw $t1, 4216($t0)
        sw $t1, 4236($t0)
        sw $t1, 4240($t0)
        sw $t1, 4252($t0)
        sw $t1, 4256($t0)
        sw $t1, 4272($t0)
        sw $t1, 4296($t0)
        sw $t1, 4308($t0)
        sw $t1, 4312($t0)
        sw $t1, 4372($t0)
        sw $t1, 4392($t0)
        sw $t1, 4396($t0)
        sw $t1, 4424($t0)
        sw $t1, 4432($t0)
        sw $t1, 4448($t0)
        sw $t1, 4472($t0)
        sw $t1, 4496($t0)
        sw $t1, 4512($t0)
        sw $t1, 4528($t0)
        sw $t1, 4552($t0)
        sw $t1, 4568($t0)
        sw $t1, 4572($t0)
        sw $t1, 4576($t0)
        sw $t1, 4628($t0)
        sw $t1, 4648($t0)
        sw $t1, 4652($t0)
        sw $t1, 4656($t0)
        sw $t1, 4680($t0)
        sw $t1, 4684($t0)
        sw $t1, 4688($t0)
        sw $t1, 4700($t0)
        sw $t1, 4704($t0)
        sw $t1, 4728($t0)
        sw $t1, 4748($t0)
        sw $t1, 4752($t0)
        sw $t1, 4768($t0)
        sw $t1, 4780($t0)
        sw $t1, 4784($t0)
        sw $t1, 4808($t0)
        sw $t1, 4832($t0)
        sw $t1, 4836($t0)
        sw $t1, 4856($t0)
        sw $t1, 4884($t0)
        sw $t1, 4900($t0)
        sw $t1, 4912($t0)
        sw $t1, 4936($t0)
        sw $t1, 4956($t0)
        sw $t1, 4984($t0)
        sw $t1, 5004($t0)
        sw $t1, 5020($t0)
        sw $t1, 5024($t0)
        sw $t1, 5036($t0)
        sw $t1, 5064($t0)
        sw $t1, 5092($t0)
        sw $t1, 5108($t0)
        sw $t1, 5112($t0)
        sw $t1, 5116($t0)
        sw $t1, 5140($t0)
        sw $t1, 5156($t0)
        sw $t1, 5168($t0)
        sw $t1, 5188($t0)
        sw $t1, 5192($t0)
        sw $t1, 5212($t0)
        sw $t1, 5232($t0)
        sw $t1, 5240($t0)
        sw $t1, 5244($t0)
        sw $t1, 5256($t0)
        sw $t1, 5260($t0)
        sw $t1, 5276($t0)
        sw $t1, 5292($t0)
        sw $t1, 5320($t0)
        sw $t1, 5328($t0)
        sw $t1, 5332($t0)
        sw $t1, 5348($t0)
        sw $t1, 5368($t0)
        sw $t1, 5396($t0)
        sw $t1, 5400($t0)
        sw $t1, 5412($t0)
        sw $t1, 5424($t0)
        sw $t1, 5440($t0)
        sw $t1, 5444($t0)
        sw $t1, 5472($t0)
        sw $t1, 5484($t0)
        sw $t1, 5488($t0)
        sw $t1, 5500($t0)
        sw $t1, 5504($t0)
        sw $t1, 5508($t0)
        sw $t1, 5512($t0)
        sw $t1, 5532($t0)
        sw $t1, 5548($t0)
        sw $t1, 5576($t0)
        sw $t1, 5588($t0)
        sw $t1, 5592($t0)
        sw $t1, 5600($t0)
        sw $t1, 5604($t0)
        sw $t1, 5656($t0)
        sw $t1, 5660($t0)
        sw $t1, 5664($t0)
        sw $t1, 5668($t0)
        sw $t1, 5680($t0)
        sw $t1, 5684($t0)
        sw $t1, 5688($t0)
        sw $t1, 5692($t0)
        sw $t1, 5696($t0)
        sw $t1, 5732($t0)
        sw $t1, 5736($t0)
        sw $t1, 5740($t0)
        sw $t1, 5848($t0)
        sw $t1, 5852($t0)
        sw $t1, 5856($t0)
        sw $t1, 6676($t0)
        sw $t1, 6932($t0)
        sw $t1, 6936($t0)
        sw $t2, 7972($t0)
        sw $t2, 7976($t0)
        sw $t2, 7980($t0)
        sw $t2, 7984($t0)
        sw $t2, 8224($t0)
        sw $t2, 8228($t0)
        sw $t2, 8232($t0)
        sw $t2, 8236($t0)
        sw $t2, 8240($t0)
        sw $t2, 8244($t0)
        sw $t3, 8476($t0)
        sw $t2, 8480($t0)
        sw $t2, 8484($t0)
        sw $t4, 8488($t0)
        sw $t4, 8492($t0)
        sw $t4, 8496($t0)
        sw $t4, 8500($t0)
        sw $t4, 8504($t0)
        sw $t3, 8728($t0)
        sw $t3, 8732($t0)
        sw $t2, 8736($t0)
        sw $t2, 8740($t0)
        sw $t4, 8744($t0)
        sw $t4, 8748($t0)
        sw $t4, 8752($t0)
        sw $t4, 8756($t0)
        sw $t4, 8760($t0)
        sw $t3, 8984($t0)
        sw $t3, 8988($t0)
        sw $t2, 8992($t0)
        sw $t2, 8996($t0)
        sw $t2, 9000($t0)
        sw $t2, 9004($t0)
        sw $t2, 9008($t0)
        sw $t2, 9012($t0)
        sw $t1, 9200($t0)
        sw $t3, 9240($t0)
        sw $t3, 9244($t0)
        sw $t2, 9248($t0)
        sw $t2, 9252($t0)
        sw $t2, 9256($t0)
        sw $t2, 9260($t0)
        sw $t2, 9264($t0)
        sw $t2, 9268($t0)
        sw $t3, 9500($t0)
        sw $t2, 9504($t0)
        sw $t2, 9508($t0)
        sw $t2, 9512($t0)
        sw $t2, 9516($t0)
        sw $t2, 9520($t0)
        sw $t2, 9524($t0)
        sw $t2, 9760($t0)
        sw $t2, 9764($t0)
        sw $t2, 9768($t0)
        sw $t2, 9772($t0)
        sw $t2, 9776($t0)
        sw $t2, 9780($t0)
        sw $t2, 9784($t0)
        sw $t2, 10024($t0)
        sw $t2, 10040($t0)
        sw $t2, 10280($t0)
        sw $t2, 10284($t0)
        sw $t2, 10296($t0)
        sw $t2, 10300($t0)
        sw $t1, 14716($t0)
        sw $t1, 15384($t0)
        sw $t1, 15584($t0)
        sw $t1, 15588($t0)
        sw $t1, 15636($t0)
        sw $t1, 15640($t0)
        sw $t1, 15840($t0)
        sw $t3, 15196($t0)
        sw $t3, 15200($t0)
        sw $t3, 15208($t0)
        sw $t3, 15212($t0)
        sw $t3, 15228($t0)
        sw $t3, 15244($t0)
        sw $t3, 15260($t0)
        sw $t3, 15264($t0)
        sw $t3, 15424($t0)
        sw $t3, 15436($t0)
        sw $t3, 15448($t0)
        sw $t3, 15464($t0)
        sw $t3, 15472($t0)
        sw $t3, 15480($t0)
        sw $t3, 15488($t0)
        sw $t3, 15496($t0)
        sw $t3, 15504($t0)
        sw $t3, 15512($t0)
        sw $t3, 15536($t0)
        sw $t3, 15548($t0)
        sw $t3, 15684($t0)
        sw $t3, 15696($t0)
        sw $t3, 15708($t0)
        sw $t3, 15720($t0)
        sw $t3, 15724($t0)
        sw $t3, 15736($t0)
        sw $t3, 15744($t0)
        sw $t3, 15752($t0)
        sw $t3, 15768($t0)
        sw $t3, 15772($t0)
        sw $t3, 15788($t0)
        sw $t3, 15800($t0)
        sw $t3, 15936($t0)
        sw $t3, 15948($t0)
        sw $t3, 15968($t0)
        sw $t3, 15976($t0)
        sw $t3, 15992($t0)
        sw $t3, 15996($t0)
        sw $t3, 16000($t0)
        sw $t3, 16008($t0)
        sw $t3, 16016($t0)
        sw $t3, 16024($t0)
        sw $t3, 16048($t0)
        sw $t3, 16060($t0)
        sw $t3, 16216($t0)
        sw $t3, 16220($t0)
        sw $t3, 16232($t0)
        sw $t3, 16248($t0)
        sw $t3, 16256($t0)
        sw $t3, 16268($t0)
        sw $t3, 16284($t0)
        sw $t3, 16288($t0)
	jr $ra
	
but1:   la $t0, BASE_ADDRESS
        sw $t1, 9824($t0)
        sw $t1, 9828($t0)
        sw $t1, 9832($t0)
        sw $t1, 9992($t0)
        sw $t1, 9996($t0)
        sw $t1, 10000($t0)
        sw $t1, 10004($t0)
        sw $t1, 10008($t0)
        sw $t1, 10012($t0)
        sw $t1, 10016($t0)
        sw $t1, 10020($t0)
        sw $t1, 10028($t0)
        sw $t1, 10032($t0)
        sw $t1, 10036($t0)
        sw $t1, 10044($t0)
        sw $t1, 10048($t0)
        sw $t1, 10052($t0)
        sw $t1, 10056($t0)
        sw $t1, 10060($t0)
        sw $t1, 10064($t0)
        sw $t1, 10068($t0)
        sw $t1, 10072($t0)
        sw $t1, 10076($t0)
        sw $t1, 10080($t0)
        sw $t1, 10088($t0)
        sw $t1, 10092($t0)
        sw $t1, 10096($t0)
        sw $t1, 10100($t0)
        sw $t1, 10248($t0)
        sw $t1, 10356($t0)
        sw $t1, 10360($t0)
        sw $t1, 10504($t0)
        sw $t1, 10616($t0)
        sw $t1, 10756($t0)
        sw $t1, 10760($t0)
        sw $t1, 10768($t0)
        sw $t1, 10772($t0)
        sw $t1, 10776($t0)
        sw $t1, 10784($t0)
        sw $t1, 10788($t0)
        sw $t1, 10792($t0)
        sw $t1, 10796($t0)
        sw $t1, 10808($t0)
        sw $t1, 10828($t0)
        sw $t1, 10832($t0)
        sw $t1, 10836($t0)
        sw $t1, 10848($t0)
        sw $t1, 10852($t0)
        sw $t1, 10856($t0)
        sw $t1, 10860($t0)
        sw $t1, 10872($t0)
        sw $t1, 11012($t0)
        sw $t1, 11024($t0)
        sw $t1, 11032($t0)
        sw $t1, 11044($t0)
        sw $t1, 11064($t0)
        sw $t1, 11068($t0)
        sw $t1, 11084($t0)
        sw $t1, 11092($t0)
        sw $t1, 11096($t0)
        sw $t1, 11108($t0)
        sw $t1, 11128($t0)
        sw $t1, 11268($t0)
        sw $t1, 11280($t0)
        sw $t1, 11300($t0)
        sw $t1, 11320($t0)
        sw $t1, 11324($t0)
        sw $t1, 11340($t0)
        sw $t1, 11352($t0)
        sw $t1, 11364($t0)
        sw $t1, 11380($t0)
        sw $t1, 11384($t0)
        sw $t1, 11524($t0)
        sw $t1, 11536($t0)
        sw $t1, 11556($t0)
        sw $t1, 11560($t0)
        sw $t1, 11572($t0)
        sw $t1, 11576($t0)
        sw $t1, 11580($t0)
        sw $t1, 11592($t0)
        sw $t1, 11596($t0)
        sw $t1, 11608($t0)
        sw $t1, 11620($t0)
        sw $t1, 11624($t0)
        sw $t1, 11636($t0)
        sw $t1, 11780($t0)
        sw $t1, 11792($t0)
        sw $t1, 11796($t0)
        sw $t1, 11816($t0)
        sw $t1, 11828($t0)
        sw $t1, 11836($t0)
        sw $t1, 11848($t0)
        sw $t1, 11864($t0)
        sw $t1, 11880($t0)
        sw $t1, 11892($t0)
        sw $t1, 12036($t0)
        sw $t1, 12052($t0)
        sw $t1, 12056($t0)
        sw $t1, 12072($t0)
        sw $t1, 12084($t0)
        sw $t1, 12092($t0)
        sw $t1, 12104($t0)
        sw $t1, 12120($t0)
        sw $t1, 12136($t0)
        sw $t1, 12148($t0)
        sw $t1, 12152($t0)
        sw $t1, 12292($t0)
        sw $t1, 12312($t0)
        sw $t1, 12328($t0)
        sw $t1, 12340($t0)
        sw $t1, 12348($t0)
        sw $t1, 12352($t0)
        sw $t1, 12360($t0)
        sw $t1, 12364($t0)
        sw $t1, 12372($t0)
        sw $t1, 12376($t0)
        sw $t1, 12392($t0)
        sw $t1, 12408($t0)
        sw $t1, 12548($t0)
        sw $t1, 12568($t0)
        sw $t1, 12584($t0)
        sw $t1, 12596($t0)
        sw $t1, 12608($t0)
        sw $t1, 12620($t0)
        sw $t1, 12624($t0)
        sw $t1, 12628($t0)
        sw $t1, 12648($t0)
        sw $t1, 12664($t0)
        sw $t1, 12804($t0)
        sw $t1, 12824($t0)
        sw $t1, 12840($t0)
        sw $t1, 12852($t0)
        sw $t1, 12856($t0)
        sw $t1, 12860($t0)
        sw $t1, 12864($t0)
        sw $t1, 12876($t0)
        sw $t1, 12880($t0)
        sw $t1, 12904($t0)
        sw $t1, 12920($t0)
        sw $t1, 13060($t0)
        sw $t1, 13080($t0)
        sw $t1, 13092($t0)
        sw $t1, 13096($t0)
        sw $t1, 13108($t0)
        sw $t1, 13120($t0)
        sw $t1, 13132($t0)
        sw $t1, 13136($t0)
        sw $t1, 13140($t0)
        sw $t1, 13156($t0)
        sw $t1, 13160($t0)
        sw $t1, 13176($t0)
        sw $t1, 13316($t0)
        sw $t1, 13336($t0)
        sw $t1, 13348($t0)
        sw $t1, 13364($t0)
        sw $t1, 13376($t0)
        sw $t1, 13388($t0)
        sw $t1, 13396($t0)
        sw $t1, 13400($t0)
        sw $t1, 13412($t0)
        sw $t1, 13432($t0)
        sw $t1, 13572($t0)
        sw $t1, 13580($t0)
        sw $t1, 13584($t0)
        sw $t1, 13588($t0)
        sw $t1, 13592($t0)
        sw $t1, 13604($t0)
        sw $t1, 13616($t0)
        sw $t1, 13620($t0)
        sw $t1, 13632($t0)
        sw $t1, 13636($t0)
        sw $t1, 13644($t0)
        sw $t1, 13656($t0)
        sw $t1, 13660($t0)
        sw $t1, 13668($t0)
        sw $t1, 13688($t0)
        sw $t1, 13828($t0)
        sw $t1, 13840($t0)
        sw $t1, 13844($t0)
        sw $t1, 13860($t0)
        sw $t1, 13872($t0)
        sw $t1, 13892($t0)
        sw $t1, 13900($t0)
        sw $t1, 13916($t0)
        sw $t1, 13924($t0)
        sw $t1, 13944($t0)
        sw $t1, 14084($t0)
        sw $t1, 14088($t0)
        sw $t1, 14196($t0)
        sw $t1, 14200($t0)
        sw $t1, 14344($t0)
        sw $t1, 14348($t0)
        sw $t1, 14380($t0)
        sw $t1, 14384($t0)
        sw $t1, 14388($t0)
        sw $t1, 14440($t0)
        sw $t1, 14444($t0)
        sw $t1, 14448($t0)
        sw $t1, 14452($t0)
        sw $t1, 14604($t0)
        sw $t1, 14608($t0)
        sw $t1, 14612($t0)
        sw $t1, 14616($t0)
        sw $t1, 14620($t0)
        sw $t1, 14624($t0)
        sw $t1, 14628($t0)
        sw $t1, 14632($t0)
        sw $t1, 14636($t0)
        sw $t1, 14644($t0)
        sw $t1, 14648($t0)
        sw $t1, 14652($t0)
        sw $t1, 14656($t0)
        sw $t1, 14660($t0)
        sw $t1, 14664($t0)
        sw $t1, 14668($t0)
        sw $t1, 14672($t0)
        sw $t1, 14676($t0)
        sw $t1, 14680($t0)
        sw $t1, 14684($t0)
        sw $t1, 14688($t0)
        sw $t1, 14692($t0)
        sw $t1, 14696($t0)
	jr $ra
	
but2: 	la $t0, BASE_ADDRESS
        sw $t1, 9896($t0)
        sw $t1, 9900($t0)
        sw $t1, 9904($t0)
        sw $t1, 9908($t0)
        sw $t1, 9912($t0)
        sw $t1, 9948($t0)
        sw $t1, 9952($t0)
        sw $t1, 9956($t0)
        sw $t1, 9960($t0)
        sw $t1, 10124($t0)
        sw $t1, 10128($t0)
        sw $t1, 10132($t0)
        sw $t1, 10136($t0)
        sw $t1, 10140($t0)
        sw $t1, 10144($t0)
        sw $t1, 10148($t0)
        sw $t1, 10168($t0)
        sw $t1, 10172($t0)
        sw $t1, 10176($t0)
        sw $t1, 10180($t0)
        sw $t1, 10184($t0)
        sw $t1, 10188($t0)
        sw $t1, 10192($t0)
        sw $t1, 10196($t0)
        sw $t1, 10200($t0)
        sw $t1, 10220($t0)
        sw $t1, 10224($t0)
        sw $t1, 10376($t0)
        sw $t1, 10480($t0)
        sw $t1, 10484($t0)
        sw $t1, 10632($t0)
        sw $t1, 10648($t0)
        sw $t1, 10652($t0)
        sw $t1, 10656($t0)
        sw $t1, 10660($t0)
        sw $t1, 10668($t0)
        sw $t1, 10684($t0)
        sw $t1, 10688($t0)
        sw $t1, 10696($t0)
        sw $t1, 10708($t0)
        sw $t1, 10712($t0)
        sw $t1, 10716($t0)
        sw $t1, 10720($t0)
        sw $t1, 10724($t0)
        sw $t1, 10740($t0)
        sw $t1, 10744($t0)
        sw $t1, 10888($t0)
        sw $t1, 10900($t0)
        sw $t1, 10904($t0)
        sw $t1, 10924($t0)
        sw $t1, 10940($t0)
        sw $t1, 10952($t0)
        sw $t1, 10972($t0)
        sw $t1, 11000($t0)
        sw $t1, 11140($t0)
        sw $t1, 11144($t0)
        sw $t1, 11156($t0)
        sw $t1, 11180($t0)
        sw $t1, 11196($t0)
        sw $t1, 11208($t0)
        sw $t1, 11212($t0)
        sw $t1, 11228($t0)
        sw $t1, 11256($t0)
        sw $t1, 11396($t0)
        sw $t1, 11412($t0)
        sw $t1, 11440($t0)
        sw $t1, 11452($t0)
        sw $t1, 11468($t0)
        sw $t1, 11484($t0)
        sw $t1, 11488($t0)
        sw $t1, 11512($t0)
        sw $t1, 11652($t0)
        sw $t1, 11668($t0)
        sw $t1, 11696($t0)
        sw $t1, 11700($t0)
        sw $t1, 11708($t0)
        sw $t1, 11724($t0)
        sw $t1, 11744($t0)
        sw $t1, 11768($t0)
        sw $t1, 11908($t0)
        sw $t1, 11924($t0)
        sw $t1, 11956($t0)
        sw $t1, 11960($t0)
        sw $t1, 11964($t0)
        sw $t1, 11980($t0)
        sw $t1, 12000($t0)
        sw $t1, 12024($t0)
        sw $t1, 12164($t0)
        sw $t1, 12180($t0)
        sw $t1, 12184($t0)
        sw $t1, 12188($t0)
        sw $t1, 12212($t0)
        sw $t1, 12236($t0)
        sw $t1, 12256($t0)
        sw $t1, 12280($t0)
        sw $t1, 12420($t0)
        sw $t1, 12436($t0)
        sw $t1, 12468($t0)
        sw $t1, 12472($t0)
        sw $t1, 12492($t0)
        sw $t1, 12512($t0)
        sw $t1, 12536($t0)
        sw $t1, 12676($t0)
        sw $t1, 12692($t0)
        sw $t1, 12720($t0)
        sw $t1, 12724($t0)
        sw $t1, 12728($t0)
        sw $t1, 12748($t0)
        sw $t1, 12768($t0)
        sw $t1, 12792($t0)
        sw $t1, 12932($t0)
        sw $t1, 12948($t0)
        sw $t1, 12976($t0)
        sw $t1, 12984($t0)
        sw $t1, 13004($t0)
        sw $t1, 13024($t0)
        sw $t1, 13048($t0)
        sw $t1, 13188($t0)
        sw $t1, 13204($t0)
        sw $t1, 13232($t0)
        sw $t1, 13240($t0)
        sw $t1, 13260($t0)
        sw $t1, 13276($t0)
        sw $t1, 13280($t0)
        sw $t1, 13304($t0)
        sw $t1, 13444($t0)
        sw $t1, 13460($t0)
        sw $t1, 13488($t0)
        sw $t1, 13496($t0)
        sw $t1, 13500($t0)
        sw $t1, 13516($t0)
        sw $t1, 13532($t0)
        sw $t1, 13560($t0)
        sw $t1, 13700($t0)
        sw $t1, 13716($t0)
        sw $t1, 13720($t0)
        sw $t1, 13740($t0)
        sw $t1, 13744($t0)
        sw $t1, 13756($t0)
        sw $t1, 13760($t0)
        sw $t1, 13772($t0)
        sw $t1, 13788($t0)
        sw $t1, 13816($t0)
        sw $t1, 13956($t0)
        sw $t1, 13976($t0)
        sw $t1, 13980($t0)
        sw $t1, 13984($t0)
        sw $t1, 13988($t0)
        sw $t1, 13996($t0)
        sw $t1, 14016($t0)
        sw $t1, 14024($t0)
        sw $t1, 14028($t0)
        sw $t1, 14044($t0)
        sw $t1, 14072($t0)
        sw $t1, 14212($t0)
        sw $t1, 14216($t0)
        sw $t1, 14328($t0)
        sw $t1, 14472($t0)
        sw $t1, 14476($t0)
        sw $t1, 14480($t0)
        sw $t1, 14508($t0)
        sw $t1, 14512($t0)
        sw $t1, 14516($t0)
        sw $t1, 14572($t0)
        sw $t1, 14576($t0)
        sw $t1, 14580($t0)
        sw $t1, 14584($t0)
        sw $t1, 14736($t0)
        sw $t1, 14740($t0)
        sw $t1, 14744($t0)
        sw $t1, 14748($t0)
        sw $t1, 14752($t0)
        sw $t1, 14756($t0)
        sw $t1, 14760($t0)
        sw $t1, 14764($t0)
        sw $t1, 14772($t0)
        sw $t1, 14776($t0)
        sw $t1, 14780($t0)
        sw $t1, 14784($t0)
        sw $t1, 14788($t0)
        sw $t1, 14792($t0)
        sw $t1, 14796($t0)
        sw $t1, 14800($t0)
        sw $t1, 14804($t0)
        sw $t1, 14808($t0)
        sw $t1, 14812($t0)
        sw $t1, 14816($t0)
        sw $t1, 14820($t0)
        sw $t1, 14824($t0)
        sw $t1, 14828($t0)
	jr $ra
	
but3:	la $t0, BASE_ADDRESS
        sw $t1, 11528($t0)
        sw $t1, 11532($t0)
        sw $t1, 11548($t0)
        sw $t1, 11552($t0)
        sw $t1, 11556($t0)
        sw $t1, 11572($t0)
        sw $t1, 11576($t0)
        sw $t1, 11580($t0)
        sw $t1, 11584($t0)
        sw $t1, 11588($t0)
        sw $t1, 11608($t0)
        sw $t1, 11612($t0)
        sw $t1, 11616($t0)
        sw $t1, 11620($t0)
        sw $t1, 11624($t0)
        sw $t1, 11780($t0)
        sw $t1, 11792($t0)
        sw $t1, 11796($t0)
        sw $t1, 11800($t0)
        sw $t1, 11812($t0)
        sw $t1, 11816($t0)
        sw $t1, 11820($t0)
        sw $t1, 11824($t0)
        sw $t1, 11848($t0)
        sw $t1, 11852($t0)
        sw $t1, 11856($t0)
        sw $t1, 11860($t0)
        sw $t1, 11880($t0)
        sw $t1, 11884($t0)
        sw $t1, 11888($t0)
        sw $t1, 11892($t0)
        sw $t1, 12032($t0)
        sw $t1, 12036($t0)
        sw $t1, 12148($t0)
        sw $t1, 12288($t0)
        sw $t1, 12300($t0)
        sw $t1, 12324($t0)
        sw $t1, 12336($t0)
        sw $t1, 12340($t0)
        sw $t1, 12348($t0)
        sw $t1, 12356($t0)
        sw $t1, 12360($t0)
        sw $t1, 12364($t0)
        sw $t1, 12376($t0)
        sw $t1, 12392($t0)
        sw $t1, 12408($t0)
        sw $t1, 12544($t0)
        sw $t1, 12556($t0)
        sw $t1, 12576($t0)
        sw $t1, 12580($t0)
        sw $t1, 12588($t0)
        sw $t1, 12592($t0)
        sw $t1, 12604($t0)
        sw $t1, 12608($t0)
        sw $t1, 12612($t0)
        sw $t1, 12624($t0)
        sw $t1, 12632($t0)
        sw $t1, 12648($t0)
        sw $t1, 12664($t0)
        sw $t1, 12800($t0)
        sw $t1, 12812($t0)
        sw $t1, 12816($t0)
        sw $t1, 12828($t0)
        sw $t1, 12832($t0)
        sw $t1, 12836($t0)
        sw $t1, 12844($t0)
        sw $t1, 12848($t0)
        sw $t1, 12860($t0)
        sw $t1, 12880($t0)
        sw $t1, 12888($t0)
        sw $t1, 12904($t0)
        sw $t1, 12920($t0)
        sw $t1, 13056($t0)
        sw $t1, 13068($t0)
        sw $t1, 13072($t0)
        sw $t1, 13076($t0)
        sw $t1, 13084($t0)
        sw $t1, 13092($t0)
        sw $t1, 13100($t0)
        sw $t1, 13116($t0)
        sw $t1, 13136($t0)
        sw $t1, 13144($t0)
        sw $t1, 13160($t0)
        sw $t1, 13176($t0)
        sw $t1, 13312($t0)
        sw $t1, 13324($t0)
        sw $t1, 13332($t0)
        sw $t1, 13340($t0)
        sw $t1, 13348($t0)
        sw $t1, 13356($t0)
        sw $t1, 13372($t0)
        sw $t1, 13392($t0)
        sw $t1, 13400($t0)
        sw $t1, 13416($t0)
        sw $t1, 13432($t0)
        sw $t1, 13568($t0)
        sw $t1, 13580($t0)
        sw $t1, 13588($t0)
        sw $t1, 13592($t0)
        sw $t1, 13604($t0)
        sw $t1, 13612($t0)
        sw $t1, 13628($t0)
        sw $t1, 13648($t0)
        sw $t1, 13656($t0)
        sw $t1, 13672($t0)
        sw $t1, 13688($t0)
        sw $t1, 13824($t0)
        sw $t1, 13836($t0)
        sw $t1, 13860($t0)
        sw $t1, 13868($t0)
        sw $t1, 13872($t0)
        sw $t1, 13876($t0)
        sw $t1, 13884($t0)
        sw $t1, 13888($t0)
        sw $t1, 13904($t0)
        sw $t1, 13912($t0)
        sw $t1, 13928($t0)
        sw $t1, 13944($t0)
        sw $t1, 14080($t0)
        sw $t1, 14092($t0)
        sw $t1, 14116($t0)
        sw $t1, 14124($t0)
        sw $t1, 14144($t0)
        sw $t1, 14160($t0)
        sw $t1, 14168($t0)
        sw $t1, 14184($t0)
        sw $t1, 14200($t0)
        sw $t1, 14336($t0)
        sw $t1, 14348($t0)
        sw $t1, 14372($t0)
        sw $t1, 14380($t0)
        sw $t1, 14400($t0)
        sw $t1, 14416($t0)
        sw $t1, 14424($t0)
        sw $t1, 14436($t0)
        sw $t1, 14440($t0)
        sw $t1, 14456($t0)
        sw $t1, 14592($t0)
        sw $t1, 14604($t0)
        sw $t1, 14628($t0)
        sw $t1, 14636($t0)
        sw $t1, 14652($t0)
        sw $t1, 14656($t0)
        sw $t1, 14672($t0)
        sw $t1, 14680($t0)
        sw $t1, 14684($t0)
        sw $t1, 14688($t0)
        sw $t1, 14692($t0)
        sw $t1, 14700($t0)
        sw $t1, 14712($t0)
        sw $t1, 14848($t0)
        sw $t1, 14860($t0)
        sw $t1, 14884($t0)
        sw $t1, 14896($t0)
        sw $t1, 14900($t0)
        sw $t1, 14908($t0)
        sw $t1, 14928($t0)
        sw $t1, 14940($t0)
        sw $t1, 14944($t0)
        sw $t1, 14956($t0)
        sw $t1, 14968($t0)
        sw $t1, 15108($t0)
        sw $t1, 15224($t0)
        sw $t1, 15364($t0)
        sw $t1, 15368($t0)
        sw $t1, 15476($t0)
        sw $t1, 15628($t0)
        sw $t1, 15632($t0)
        sw $t1, 15636($t0)
        sw $t1, 15640($t0)
        sw $t1, 15644($t0)
        sw $t1, 15648($t0)
        sw $t1, 15652($t0)
        sw $t1, 15656($t0)
        sw $t1, 15660($t0)
        sw $t1, 15664($t0)
        sw $t1, 15668($t0)
        sw $t1, 15672($t0)
        sw $t1, 15676($t0)
        sw $t1, 15680($t0)
        sw $t1, 15684($t0)
        sw $t1, 15688($t0)
        sw $t1, 15692($t0)
        sw $t1, 15696($t0)
        sw $t1, 15700($t0)
        sw $t1, 15704($t0)
        sw $t1, 15708($t0)
        sw $t1, 15712($t0)
        sw $t1, 15716($t0)
        sw $t1, 15720($t0)
        sw $t1, 15724($t0)
        sw $t1, 15728($t0)
	jr $ra
but4:	la $t0, BASE_ADDRESS
        sw $t1, 11660($t0)
        sw $t1, 11664($t0)
        sw $t1, 11680($t0)
        sw $t1, 11684($t0)
        sw $t1, 11688($t0)
        sw $t1, 11704($t0)
        sw $t1, 11708($t0)
        sw $t1, 11712($t0)
        sw $t1, 11716($t0)
        sw $t1, 11720($t0)
        sw $t1, 11740($t0)
        sw $t1, 11744($t0)
        sw $t1, 11748($t0)
        sw $t1, 11752($t0)
        sw $t1, 11756($t0)
        sw $t1, 11912($t0)
        sw $t1, 11924($t0)
        sw $t1, 11928($t0)
        sw $t1, 11932($t0)
        sw $t1, 11944($t0)
        sw $t1, 11948($t0)
        sw $t1, 11952($t0)
        sw $t1, 11956($t0)
        sw $t1, 11980($t0)
        sw $t1, 11984($t0)
        sw $t1, 11988($t0)
        sw $t1, 11992($t0)
        sw $t1, 12012($t0)
        sw $t1, 12016($t0)
        sw $t1, 12020($t0)
        sw $t1, 12024($t0)
        sw $t1, 12164($t0)
        sw $t1, 12168($t0)
        sw $t1, 12280($t0)
        sw $t1, 12420($t0)
        sw $t1, 12440($t0)
        sw $t1, 12444($t0)
        sw $t1, 12448($t0)
        sw $t1, 12452($t0)
        sw $t1, 12460($t0)
        sw $t1, 12480($t0)
        sw $t1, 12492($t0)
        sw $t1, 12504($t0)
        sw $t1, 12508($t0)
        sw $t1, 12512($t0)
        sw $t1, 12516($t0)
        sw $t1, 12520($t0)
        sw $t1, 12540($t0)
        sw $t1, 12676($t0)
        sw $t1, 12696($t0)
        sw $t1, 12716($t0)
        sw $t1, 12732($t0)
        sw $t1, 12748($t0)
        sw $t1, 12768($t0)
        sw $t1, 12796($t0)
        sw $t1, 12932($t0)
        sw $t1, 12952($t0)
        sw $t1, 12976($t0)
        sw $t1, 12988($t0)
        sw $t1, 13004($t0)
        sw $t1, 13024($t0)
        sw $t1, 13052($t0)
        sw $t1, 13188($t0)
        sw $t1, 13208($t0)
        sw $t1, 13232($t0)
        sw $t1, 13240($t0)
        sw $t1, 13260($t0)
        sw $t1, 13284($t0)
        sw $t1, 13308($t0)
        sw $t1, 13444($t0)
        sw $t1, 13460($t0)
        sw $t1, 13464($t0)
        sw $t1, 13488($t0)
        sw $t1, 13492($t0)
        sw $t1, 13516($t0)
        sw $t1, 13540($t0)
        sw $t1, 13564($t0)
        sw $t1, 13700($t0)
        sw $t1, 13716($t0)
        sw $t1, 13748($t0)
        sw $t1, 13772($t0)
        sw $t1, 13796($t0)
        sw $t1, 13820($t0)
        sw $t1, 13956($t0)
        sw $t1, 13972($t0)
        sw $t1, 13976($t0)
        sw $t1, 13980($t0)
        sw $t1, 13984($t0)
        sw $t1, 13988($t0)
        sw $t1, 14004($t0)
        sw $t1, 14028($t0)
        sw $t1, 14048($t0)
        sw $t1, 14052($t0)
        sw $t1, 14076($t0)
        sw $t1, 14212($t0)
        sw $t1, 14228($t0)
        sw $t1, 14256($t0)
        sw $t1, 14260($t0)
        sw $t1, 14264($t0)
        sw $t1, 14280($t0)
        sw $t1, 14304($t0)
        sw $t1, 14332($t0)
        sw $t1, 14468($t0)
        sw $t1, 14484($t0)
        sw $t1, 14512($t0)
        sw $t1, 14520($t0)
        sw $t1, 14536($t0)
        sw $t1, 14560($t0)
        sw $t1, 14588($t0)
        sw $t1, 14724($t0)
        sw $t1, 14740($t0)
        sw $t1, 14764($t0)
        sw $t1, 14768($t0)
        sw $t1, 14776($t0)
        sw $t1, 14792($t0)
        sw $t1, 14816($t0)
        sw $t1, 14844($t0)
        sw $t1, 14980($t0)
        sw $t1, 15000($t0)
        sw $t1, 15020($t0)
        sw $t1, 15032($t0)
        sw $t1, 15036($t0)
        sw $t1, 15048($t0)
        sw $t1, 15072($t0)
        sw $t1, 15100($t0)
        sw $t1, 15240($t0)
        sw $t1, 15256($t0)
        sw $t1, 15260($t0)
        sw $t1, 15264($t0)
        sw $t1, 15268($t0)
        sw $t1, 15276($t0)
        sw $t1, 15292($t0)
        sw $t1, 15304($t0)
        sw $t1, 15308($t0)
        sw $t1, 15328($t0)
        sw $t1, 15356($t0)
        sw $t1, 15496($t0)
        sw $t1, 15500($t0)
        sw $t1, 15608($t0)
        sw $t1, 15760($t0)
        sw $t1, 15764($t0)
        sw $t1, 15768($t0)
        sw $t1, 15772($t0)
        sw $t1, 15776($t0)
        sw $t1, 15780($t0)
        sw $t1, 15784($t0)
        sw $t1, 15788($t0)
        sw $t1, 15792($t0)
        sw $t1, 15796($t0)
        sw $t1, 15800($t0)
        sw $t1, 15804($t0)
        sw $t1, 15808($t0)
        sw $t1, 15812($t0)
        sw $t1, 15816($t0)
        sw $t1, 15820($t0)
        sw $t1, 15824($t0)
        sw $t1, 15828($t0)
        sw $t1, 15832($t0)
        sw $t1, 15836($t0)
        sw $t1, 15840($t0)
        sw $t1, 15844($t0)
        sw $t1, 15848($t0)
        sw $t1, 15852($t0)
        sw $t1, 15856($t0)
        sw $t1, 15860($t0)
	jr $ra

heart1: la $t0, BASE_ADDRESS
        sw $t1, 520($t0)
        sw $t1, 524($t0)
        sw $t1, 540($t0)
        sw $t1, 544($t0)
        sw $t1, 776($t0)
        sw $t1, 780($t0)
        sw $t1, 784($t0)
        sw $t1, 792($t0)
        sw $t1, 796($t0)
        sw $t1, 800($t0)
        sw $t1, 1036($t0)
        sw $t1, 1040($t0)
        sw $t1, 1044($t0)
        sw $t1, 1048($t0)
        sw $t1, 1052($t0)
        sw $t1, 1296($t0)
        sw $t1, 1300($t0)
        sw $t1, 1304($t0)
        sw $t1, 1556($t0)
        jr $ra
heart2: la $t0, BASE_ADDRESS
        sw $t1, 560($t0)
        sw $t1, 564($t0)
        sw $t1, 580($t0)
        sw $t1, 584($t0)
        sw $t1, 816($t0)
        sw $t1, 820($t0)
        sw $t1, 824($t0)
        sw $t1, 832($t0)
        sw $t1, 836($t0)
        sw $t1, 840($t0)
        sw $t1, 1076($t0)
        sw $t1, 1080($t0)
        sw $t1, 1084($t0)
        sw $t1, 1088($t0)
        sw $t1, 1092($t0)
        sw $t1, 1336($t0)
        sw $t1, 1340($t0)
        sw $t1, 1344($t0)
        sw $t1, 1596($t0)
	jr $ra
heart3: la $t0, BASE_ADDRESS
        sw $t1, 600($t0)
        sw $t1, 604($t0)
        sw $t1, 620($t0)
        sw $t1, 624($t0)
        sw $t1, 856($t0)
        sw $t1, 860($t0)
        sw $t1, 864($t0)
        sw $t1, 872($t0)
        sw $t1, 876($t0)
        sw $t1, 880($t0)
        sw $t1, 1116($t0)
        sw $t1, 1120($t0)
        sw $t1, 1124($t0)
        sw $t1, 1128($t0)
        sw $t1, 1132($t0)
        sw $t1, 1376($t0)
        sw $t1, 1380($t0)
        sw $t1, 1384($t0)
        sw $t1, 1636($t0)
	jr $ra
	
sussy:	la $t0, BASE_ADDRESS
        li $t1, 0xab2222
        li $t2, 0xffffff
        li $t3, 0x661616
        li $t4, 0x3d0f0f
        sw $t1, 6256($t0)
        sw $t1, 6260($t0)
        sw $t1, 6264($t0)
        sw $t1, 6268($t0)
        sw $t1, 6272($t0)
        sw $t1, 6276($t0)
        sw $t1, 6280($t0)
        sw $t1, 6284($t0)
        sw $t1, 6288($t0)
        sw $t1, 6512($t0)
        sw $t1, 6516($t0)
        sw $t1, 6520($t0)
        sw $t1, 6524($t0)
        sw $t1, 6528($t0)
        sw $t1, 6532($t0)
        sw $t1, 6536($t0)
        sw $t1, 6540($t0)
        sw $t1, 6544($t0)
        sw $t1, 6548($t0)
        sw $t1, 6764($t0)
        sw $t1, 6768($t0)
        sw $t1, 6772($t0)
        sw $t1, 6776($t0)
        sw $t1, 6780($t0)
        sw $t2, 6784($t0)
        sw $t2, 6788($t0)
        sw $t2, 6792($t0)
        sw $t2, 6796($t0)
        sw $t2, 6800($t0)
        sw $t2, 6804($t0)
        sw $t1, 7016($t0)
        sw $t1, 7020($t0)
        sw $t1, 7024($t0)
        sw $t1, 7028($t0)
        sw $t1, 7032($t0)
        sw $t2, 7036($t0)
        sw $t2, 7040($t0)
        sw $t2, 7044($t0)
        sw $t2, 7048($t0)
        sw $t2, 7052($t0)
        sw $t2, 7056($t0)
        sw $t2, 7060($t0)
        sw $t2, 7064($t0)
        sw $t3, 7264($t0)
        sw $t3, 7268($t0)
        sw $t1, 7272($t0)
        sw $t1, 7276($t0)
        sw $t1, 7280($t0)
        sw $t1, 7284($t0)
        sw $t2, 7288($t0)
        sw $t2, 7292($t0)
        sw $t2, 7296($t0)
        sw $t2, 7300($t0)
        sw $t2, 7304($t0)
        sw $t2, 7308($t0)
        sw $t2, 7312($t0)
        sw $t2, 7316($t0)
        sw $t2, 7320($t0)
        sw $t2, 7324($t0)
        sw $t3, 7516($t0)
        sw $t3, 7520($t0)
        sw $t3, 7524($t0)
        sw $t1, 7528($t0)
        sw $t1, 7532($t0)
        sw $t1, 7536($t0)
        sw $t1, 7540($t0)
        sw $t2, 7544($t0)
        sw $t2, 7548($t0)
        sw $t2, 7552($t0)
        sw $t2, 7556($t0)
        sw $t2, 7560($t0)
        sw $t2, 7564($t0)
        sw $t2, 7568($t0)
        sw $t2, 7572($t0)
        sw $t2, 7576($t0)
        sw $t2, 7580($t0)
        sw $t3, 7772($t0)
        sw $t3, 7776($t0)
        sw $t3, 7780($t0)
        sw $t1, 7784($t0)
        sw $t1, 7788($t0)
        sw $t1, 7792($t0)
        sw $t1, 7796($t0)
        sw $t1, 7800($t0)
        sw $t2, 7804($t0)
        sw $t2, 7808($t0)
        sw $t2, 7812($t0)
        sw $t2, 7816($t0)
        sw $t2, 7820($t0)
        sw $t2, 7824($t0)
        sw $t2, 7828($t0)
        sw $t2, 7832($t0)
        sw $t3, 8028($t0)
        sw $t3, 8032($t0)
        sw $t3, 8036($t0)
        sw $t1, 8040($t0)
        sw $t1, 8044($t0)
        sw $t1, 8048($t0)
        sw $t1, 8052($t0)
        sw $t1, 8056($t0)
        sw $t1, 8060($t0)
        sw $t2, 8064($t0)
        sw $t2, 8068($t0)
        sw $t2, 8072($t0)
        sw $t2, 8076($t0)
        sw $t2, 8080($t0)
        sw $t2, 8084($t0)
        sw $t1, 8088($t0)
        sw $t3, 8284($t0)
        sw $t3, 8288($t0)
        sw $t3, 8292($t0)
        sw $t1, 8296($t0)
        sw $t1, 8300($t0)
        sw $t1, 8304($t0)
        sw $t1, 8308($t0)
        sw $t1, 8312($t0)
        sw $t1, 8316($t0)
        sw $t1, 8320($t0)
        sw $t1, 8324($t0)
        sw $t1, 8328($t0)
        sw $t1, 8332($t0)
        sw $t1, 8336($t0)
        sw $t1, 8340($t0)
        sw $t1, 8344($t0)
        sw $t3, 8540($t0)
        sw $t3, 8544($t0)
        sw $t3, 8548($t0)
        sw $t1, 8552($t0)
        sw $t1, 8556($t0)
        sw $t1, 8560($t0)
        sw $t1, 8564($t0)
        sw $t1, 8568($t0)
        sw $t1, 8572($t0)
        sw $t1, 8576($t0)
        sw $t1, 8580($t0)
        sw $t1, 8584($t0)
        sw $t1, 8588($t0)
        sw $t1, 8592($t0)
        sw $t1, 8596($t0)
        sw $t1, 8600($t0)
        sw $t3, 8796($t0)
        sw $t3, 8800($t0)
        sw $t3, 8804($t0)
        sw $t1, 8808($t0)
        sw $t1, 8812($t0)
        sw $t1, 8816($t0)
        sw $t1, 8820($t0)
        sw $t1, 8824($t0)
        sw $t1, 8828($t0)
        sw $t1, 8832($t0)
        sw $t1, 8836($t0)
        sw $t1, 8840($t0)
        sw $t1, 8844($t0)
        sw $t1, 8848($t0)
        sw $t1, 8852($t0)
        sw $t1, 8856($t0)
        sw $t3, 9052($t0)
        sw $t3, 9056($t0)
        sw $t3, 9060($t0)
        sw $t1, 9064($t0)
        sw $t1, 9068($t0)
        sw $t1, 9072($t0)
        sw $t1, 9076($t0)
        sw $t1, 9080($t0)
        sw $t1, 9084($t0)
        sw $t1, 9088($t0)
        sw $t1, 9092($t0)
        sw $t1, 9096($t0)
        sw $t1, 9100($t0)
        sw $t1, 9104($t0)
        sw $t1, 9108($t0)
        sw $t1, 9112($t0)
        sw $t3, 9308($t0)
        sw $t3, 9312($t0)
        sw $t3, 9316($t0)
        sw $t1, 9320($t0)
        sw $t1, 9324($t0)
        sw $t1, 9328($t0)
        sw $t1, 9332($t0)
        sw $t1, 9336($t0)
        sw $t1, 9340($t0)
        sw $t1, 9344($t0)
        sw $t1, 9348($t0)
        sw $t1, 9352($t0)
        sw $t1, 9356($t0)
        sw $t1, 9360($t0)
        sw $t1, 9364($t0)
        sw $t1, 9368($t0)
        sw $t3, 9568($t0)
        sw $t3, 9572($t0)
        sw $t1, 9576($t0)
        sw $t1, 9580($t0)
        sw $t1, 9584($t0)
        sw $t1, 9588($t0)
        sw $t1, 9592($t0)
        sw $t1, 9596($t0)
        sw $t1, 9600($t0)
        sw $t1, 9604($t0)
        sw $t1, 9608($t0)
        sw $t1, 9612($t0)
        sw $t1, 9616($t0)
        sw $t1, 9620($t0)
        sw $t1, 9624($t0)
        sw $t1, 9836($t0)
        sw $t1, 9840($t0)
        sw $t1, 9844($t0)
        sw $t1, 9848($t0)
        sw $t1, 9852($t0)
        sw $t1, 9856($t0)
        sw $t1, 9860($t0)
        sw $t1, 9864($t0)
        sw $t1, 9868($t0)
        sw $t1, 9872($t0)
        sw $t1, 9876($t0)
        sw $t1, 9880($t0)
        sw $t1, 10092($t0)
        sw $t1, 10096($t0)
        sw $t1, 10100($t0)
        sw $t1, 10104($t0)
        sw $t1, 10108($t0)
        sw $t1, 10120($t0)
        sw $t1, 10124($t0)
        sw $t1, 10128($t0)
        sw $t1, 10132($t0)
        sw $t1, 10136($t0)
        sw $t4, 10320($t0)
        sw $t4, 10324($t0)
        sw $t4, 10328($t0)
        sw $t4, 10332($t0)
        sw $t4, 10336($t0)
        sw $t4, 10340($t0)
        sw $t4, 10344($t0)
        sw $t4, 10348($t0)
        sw $t1, 10352($t0)
        sw $t1, 10356($t0)
        sw $t1, 10360($t0)
        sw $t4, 10364($t0)
        sw $t4, 10368($t0)
        sw $t4, 10372($t0)
        sw $t4, 10376($t0)
        sw $t1, 10380($t0)
        sw $t1, 10384($t0)
        sw $t1, 10388($t0)
        sw $t4, 10560($t0)
        sw $t4, 10564($t0)
        sw $t4, 10568($t0)
        sw $t4, 10572($t0)
        sw $t4, 10576($t0)
        sw $t4, 10580($t0)
        sw $t4, 10584($t0)
        sw $t4, 10588($t0)
        sw $t4, 10592($t0)
        sw $t4, 10596($t0)
        sw $t4, 10600($t0)
        sw $t4, 10604($t0)
        sw $t4, 10608($t0)
        sw $t4, 10612($t0)
        sw $t4, 10616($t0)
	jr $ra
        
defeat: la $t0, BASE_ADDRESS
        li $t1, 0xde0707
        sw $t1, 532($t0)
        sw $t1, 788($t0)
        sw $t1, 792($t0)
        sw $t1, 796($t0)
        sw $t1, 800($t0)
        sw $t1, 804($t0)
        sw $t1, 820($t0)
        sw $t1, 824($t0)
        sw $t1, 828($t0)
        sw $t1, 832($t0)
        sw $t1, 836($t0)
        sw $t1, 840($t0)
        sw $t1, 844($t0)
        sw $t1, 848($t0)
        sw $t1, 860($t0)
        sw $t1, 864($t0)
        sw $t1, 868($t0)
        sw $t1, 872($t0)
        sw $t1, 876($t0)
        sw $t1, 880($t0)
        sw $t1, 884($t0)
        sw $t1, 888($t0)
        sw $t1, 896($t0)
        sw $t1, 900($t0)
        sw $t1, 904($t0)
        sw $t1, 908($t0)
        sw $t1, 912($t0)
        sw $t1, 916($t0)
        sw $t1, 920($t0)
        sw $t1, 924($t0)
        sw $t1, 952($t0)
        sw $t1, 956($t0)
        sw $t1, 976($t0)
        sw $t1, 980($t0)
        sw $t1, 984($t0)
        sw $t1, 988($t0)
        sw $t1, 992($t0)
        sw $t1, 996($t0)
        sw $t1, 1000($t0)
        sw $t1, 1004($t0)
        sw $t1, 1008($t0)
        sw $t1, 1048($t0)
        sw $t1, 1060($t0)
        sw $t1, 1064($t0)
        sw $t1, 1080($t0)
        sw $t1, 1092($t0)
        sw $t1, 1096($t0)
        sw $t1, 1104($t0)
        sw $t1, 1116($t0)
        sw $t1, 1120($t0)
        sw $t1, 1156($t0)
        sw $t1, 1168($t0)
        sw $t1, 1172($t0)
        sw $t1, 1180($t0)
        sw $t1, 1208($t0)
        sw $t1, 1212($t0)
        sw $t1, 1248($t0)
        sw $t1, 1304($t0)
        sw $t1, 1320($t0)
        sw $t1, 1324($t0)
        sw $t1, 1336($t0)
        sw $t1, 1372($t0)
        sw $t1, 1412($t0)
        sw $t1, 1460($t0)
        sw $t1, 1468($t0)
        sw $t1, 1504($t0)
        sw $t1, 1556($t0)
        sw $t1, 1560($t0)
        sw $t1, 1580($t0)
        sw $t1, 1592($t0)
        sw $t1, 1628($t0)
        sw $t1, 1668($t0)
        sw $t1, 1716($t0)
        sw $t1, 1728($t0)
        sw $t1, 1760($t0)
        sw $t1, 1812($t0)
        sw $t1, 1836($t0)
        sw $t1, 1848($t0)
        sw $t1, 1884($t0)
        sw $t1, 1924($t0)
        sw $t1, 1972($t0)
        sw $t1, 1984($t0)
        sw $t1, 2016($t0)
        sw $t1, 2068($t0)
        sw $t1, 2092($t0)
        sw $t1, 2104($t0)
        sw $t1, 2140($t0)
        sw $t1, 2144($t0)
        sw $t1, 2180($t0)
        sw $t1, 2228($t0)
        sw $t1, 2240($t0)
        sw $t1, 2272($t0)
        sw $t1, 2324($t0)
        sw $t1, 2348($t0)
        sw $t1, 2360($t0)
        sw $t1, 2400($t0)
        sw $t1, 2436($t0)
        sw $t1, 2484($t0)
        sw $t1, 2496($t0)
        sw $t1, 2532($t0)
        sw $t1, 2580($t0)
        sw $t1, 2604($t0)
        sw $t1, 2616($t0)
        sw $t1, 2620($t0)
        sw $t1, 2624($t0)
        sw $t1, 2636($t0)
        sw $t1, 2656($t0)
        sw $t1, 2692($t0)
        sw $t1, 2696($t0)
        sw $t1, 2700($t0)
        sw $t1, 2712($t0)
        sw $t1, 2736($t0)
        sw $t1, 2740($t0)
        sw $t1, 2752($t0)
        sw $t1, 2788($t0)
        sw $t1, 2836($t0)
        sw $t1, 2840($t0)
        sw $t1, 2860($t0)
        sw $t1, 2872($t0)
        sw $t1, 2880($t0)
        sw $t1, 2884($t0)
        sw $t1, 2888($t0)
        sw $t1, 2912($t0)
        sw $t1, 2924($t0)
        sw $t1, 2928($t0)
        sw $t1, 2948($t0)
        sw $t1, 2956($t0)
        sw $t1, 2960($t0)
        sw $t1, 2964($t0)
        sw $t1, 2992($t0)
        sw $t1, 3012($t0)
        sw $t1, 3044($t0)
        sw $t1, 3096($t0)
        sw $t1, 3116($t0)
        sw $t1, 3128($t0)
        sw $t1, 3168($t0)
        sw $t1, 3172($t0)
        sw $t1, 3176($t0)
        sw $t1, 3184($t0)
        sw $t1, 3188($t0)
        sw $t1, 3192($t0)
        sw $t1, 3204($t0)
        sw $t1, 3248($t0)
        sw $t1, 3268($t0)
        sw $t1, 3300($t0)
        sw $t1, 3352($t0)
        sw $t1, 3372($t0)
        sw $t1, 3384($t0)
        sw $t1, 3424($t0)
        sw $t1, 3460($t0)
        sw $t1, 3504($t0)
        sw $t1, 3516($t0)
        sw $t1, 3520($t0)
        sw $t1, 3524($t0)
        sw $t1, 3556($t0)
        sw $t1, 3608($t0)
        sw $t1, 3628($t0)
        sw $t1, 3640($t0)
        sw $t1, 3680($t0)
        sw $t1, 3716($t0)
        sw $t1, 3756($t0)
        sw $t1, 3760($t0)
        sw $t1, 3764($t0)
        sw $t1, 3768($t0)
        sw $t1, 3772($t0)
        sw $t1, 3780($t0)
        sw $t1, 3812($t0)
        sw $t1, 3864($t0)
        sw $t1, 3884($t0)
        sw $t1, 3896($t0)
        sw $t1, 3936($t0)
        sw $t1, 3972($t0)
        sw $t1, 4012($t0)
        sw $t1, 4040($t0)
        sw $t1, 4068($t0)
        sw $t1, 4120($t0)
        sw $t1, 4140($t0)
        sw $t1, 4152($t0)
        sw $t1, 4192($t0)
        sw $t1, 4228($t0)
        sw $t1, 4268($t0)
        sw $t1, 4296($t0)
        sw $t1, 4324($t0)
        sw $t1, 4376($t0)
        sw $t1, 4396($t0)
        sw $t1, 4408($t0)
        sw $t1, 4444($t0)
        sw $t1, 4448($t0)
        sw $t1, 4484($t0)
        sw $t1, 4524($t0)
        sw $t1, 4552($t0)
        sw $t1, 4576($t0)
        sw $t1, 4580($t0)
        sw $t1, 4628($t0)
        sw $t1, 4632($t0)
        sw $t1, 4648($t0)
        sw $t1, 4652($t0)
        sw $t1, 4664($t0)
        sw $t1, 4700($t0)
        sw $t1, 4740($t0)
        sw $t1, 4764($t0)
        sw $t1, 4780($t0)
        sw $t1, 4808($t0)
        sw $t1, 4832($t0)
        sw $t1, 4884($t0)
        sw $t1, 4888($t0)
        sw $t1, 4892($t0)
        sw $t1, 4896($t0)
        sw $t1, 4900($t0)
        sw $t1, 4904($t0)
        sw $t1, 4920($t0)
        sw $t1, 4924($t0)
        sw $t1, 4928($t0)
        sw $t1, 4944($t0)
        sw $t1, 4956($t0)
        sw $t1, 4996($t0)
        sw $t1, 5000($t0)
        sw $t1, 5004($t0)
        sw $t1, 5016($t0)
        sw $t1, 5032($t0)
        sw $t1, 5064($t0)
        sw $t1, 5088($t0)
        sw $t1, 5144($t0)
        sw $t1, 5180($t0)
        sw $t1, 5184($t0)
        sw $t1, 5188($t0)
        sw $t1, 5192($t0)
        sw $t1, 5196($t0)
        sw $t1, 5212($t0)
        sw $t1, 5256($t0)
        sw $t1, 5260($t0)
        sw $t1, 5264($t0)
        sw $t1, 5268($t0)
        sw $t1, 5272($t0)
        sw $t1, 5288($t0)
        sw $t1, 5320($t0)
        sw $t1, 5324($t0)
        sw $t1, 5344($t0)
	jr $ra
	
victory:la $t0, BASE_ADDRESS
        li $t1, 0x4c91ff
        sw $t1, 540($t0)
        sw $t1, 580($t0)
        sw $t1, 604($t0)
        sw $t1, 608($t0)
        sw $t1, 620($t0)
        sw $t1, 624($t0)
        sw $t1, 628($t0)
        sw $t1, 632($t0)
        sw $t1, 636($t0)
        sw $t1, 640($t0)
        sw $t1, 644($t0)
        sw $t1, 660($t0)
        sw $t1, 680($t0)
        sw $t1, 684($t0)
        sw $t1, 688($t0)
        sw $t1, 692($t0)
        sw $t1, 696($t0)
        sw $t1, 700($t0)
        sw $t1, 704($t0)
        sw $t1, 716($t0)
        sw $t1, 732($t0)
        sw $t1, 796($t0)
        sw $t1, 824($t0)
        sw $t1, 828($t0)
        sw $t1, 836($t0)
        sw $t1, 852($t0)
        sw $t1, 856($t0)
        sw $t1, 868($t0)
        sw $t1, 888($t0)
        sw $t1, 912($t0)
        sw $t1, 916($t0)
        sw $t1, 920($t0)
        sw $t1, 940($t0)
        sw $t1, 944($t0)
        sw $t1, 952($t0)
        sw $t1, 960($t0)
        sw $t1, 964($t0)
        sw $t1, 972($t0)
        sw $t1, 988($t0)
        sw $t1, 1052($t0)
        sw $t1, 1056($t0)
        sw $t1, 1076($t0)
        sw $t1, 1092($t0)
        sw $t1, 1108($t0)
        sw $t1, 1124($t0)
        sw $t1, 1144($t0)
        sw $t1, 1164($t0)
        sw $t1, 1176($t0)
        sw $t1, 1196($t0)
        sw $t1, 1216($t0)
        sw $t1, 1220($t0)
        sw $t1, 1228($t0)
        sw $t1, 1244($t0)
        sw $t1, 1312($t0)
        sw $t1, 1332($t0)
        sw $t1, 1348($t0)
        sw $t1, 1364($t0)
        sw $t1, 1400($t0)
        sw $t1, 1420($t0)
        sw $t1, 1436($t0)
        sw $t1, 1452($t0)
        sw $t1, 1476($t0)
        sw $t1, 1488($t0)
        sw $t1, 1500($t0)
        sw $t1, 1568($t0)
        sw $t1, 1588($t0)
        sw $t1, 1604($t0)
        sw $t1, 1620($t0)
        sw $t1, 1656($t0)
        sw $t1, 1676($t0)
        sw $t1, 1692($t0)
        sw $t1, 1708($t0)
        sw $t1, 1732($t0)
        sw $t1, 1744($t0)
        sw $t1, 1756($t0)
        sw $t1, 1824($t0)
        sw $t1, 1844($t0)
        sw $t1, 1864($t0)
        sw $t1, 1876($t0)
        sw $t1, 1912($t0)
        sw $t1, 1928($t0)
        sw $t1, 1948($t0)
        sw $t1, 1964($t0)
        sw $t1, 1984($t0)
        sw $t1, 1988($t0)
        sw $t1, 2000($t0)
        sw $t1, 2008($t0)
        sw $t1, 2080($t0)
        sw $t1, 2100($t0)
        sw $t1, 2120($t0)
        sw $t1, 2132($t0)
        sw $t1, 2168($t0)
        sw $t1, 2184($t0)
        sw $t1, 2204($t0)
        sw $t1, 2220($t0)
        sw $t1, 2224($t0)
        sw $t1, 2240($t0)
        sw $t1, 2244($t0)
        sw $t1, 2260($t0)
        sw $t1, 2264($t0)
        sw $t1, 2336($t0)
        sw $t1, 2340($t0)
        sw $t1, 2352($t0)
        sw $t1, 2376($t0)
        sw $t1, 2388($t0)
        sw $t1, 2424($t0)
        sw $t1, 2440($t0)
        sw $t1, 2460($t0)
        sw $t1, 2476($t0)
        sw $t1, 2480($t0)
        sw $t1, 2484($t0)
        sw $t1, 2488($t0)
        sw $t1, 2492($t0)
        sw $t1, 2496($t0)
        sw $t1, 2516($t0)
        sw $t1, 2520($t0)
        sw $t1, 2596($t0)
        sw $t1, 2608($t0)
        sw $t1, 2628($t0)
        sw $t1, 2632($t0)
        sw $t1, 2644($t0)
        sw $t1, 2680($t0)
        sw $t1, 2696($t0)
        sw $t1, 2716($t0)
        sw $t1, 2732($t0)
        sw $t1, 2736($t0)
        sw $t1, 2740($t0)
        sw $t1, 2776($t0)
        sw $t1, 2852($t0)
        sw $t1, 2864($t0)
        sw $t1, 2884($t0)
        sw $t1, 2900($t0)
        sw $t1, 2936($t0)
        sw $t1, 2952($t0)
        sw $t1, 2972($t0)
        sw $t1, 2988($t0)
        sw $t1, 2996($t0)
        sw $t1, 3000($t0)
        sw $t1, 3032($t0)
        sw $t1, 3108($t0)
        sw $t1, 3112($t0)
        sw $t1, 3116($t0)
        sw $t1, 3140($t0)
        sw $t1, 3156($t0)
        sw $t1, 3192($t0)
        sw $t1, 3208($t0)
        sw $t1, 3228($t0)
        sw $t1, 3244($t0)
        sw $t1, 3256($t0)
        sw $t1, 3288($t0)
        sw $t1, 3364($t0)
        sw $t1, 3368($t0)
        sw $t1, 3372($t0)
        sw $t1, 3396($t0)
        sw $t1, 3412($t0)
        sw $t1, 3448($t0)
        sw $t1, 3464($t0)
        sw $t1, 3484($t0)
        sw $t1, 3500($t0)
        sw $t1, 3512($t0)
        sw $t1, 3516($t0)
        sw $t1, 3544($t0)
        sw $t1, 3620($t0)
        sw $t1, 3624($t0)
        sw $t1, 3628($t0)
        sw $t1, 3652($t0)
        sw $t1, 3668($t0)
        sw $t1, 3704($t0)
        sw $t1, 3720($t0)
        sw $t1, 3740($t0)
        sw $t1, 3756($t0)
        sw $t1, 3772($t0)
        sw $t1, 3776($t0)
        sw $t1, 3800($t0)
        sw $t1, 3880($t0)
        sw $t1, 3884($t0)
        sw $t1, 3908($t0)
        sw $t1, 3924($t0)
        sw $t1, 3944($t0)
        sw $t1, 3960($t0)
        sw $t1, 3980($t0)
        sw $t1, 3992($t0)
        sw $t1, 4012($t0)
        sw $t1, 4032($t0)
        sw $t1, 4056($t0)
        sw $t1, 4136($t0)
        sw $t1, 4140($t0)
        sw $t1, 4164($t0)
        sw $t1, 4184($t0)
        sw $t1, 4188($t0)
        sw $t1, 4192($t0)
        sw $t1, 4196($t0)
        sw $t1, 4200($t0)
        sw $t1, 4216($t0)
        sw $t1, 4236($t0)
        sw $t1, 4240($t0)
        sw $t1, 4244($t0)
        sw $t1, 4248($t0)
        sw $t1, 4268($t0)
        sw $t1, 4292($t0)
        sw $t1, 4312($t0)
	jr $ra

	
	
