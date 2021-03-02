j main
j Interrupt
j Exception

swap:	# $a0 = int *v; $a1 = k
	
	sll $t0 $a1 2		# $t0 = k * 4
	addu $t0 $t0 $a0		# $t0 = v + k
	
	lw $t1 ($t0)		# temp = v[k]
	
	addi $t0 $t0 4		# $t0 = v + k + 1
	
	lw $t2 ($t0)		# $t2 = v[k + 1]
	subi $t0 $t0 4		# $t0 = v + k
	sw $t2 ($t0)		# v[k] = $t2
	
	addi $t0 $t0 4		# $t0 = v + k + 1
	sw $t1 ($t0)
	
	j call_swap_end
	
bubsort:	# $a0 = int *v; $a1 = n
	subi $sp $sp 20		#save stack
	sw $ra 0($sp)		#
	sw $a0 4($sp)		#
	sw $a1 8($sp)
	sw $s0 12($sp)
	sw $s1 16($sp)
	
	li $s0 0		# $s0 store i
	li $s1 0		# $s1 store j
	
	li $s0 0		# i = 0
	
	bubsort_for:
		bge $s0 $a1 exit_bubsort_for	# if i >= n exit for
		
		subi $s1 $s0 1			# j = i - 1
		bubsort_for_2:

			blt $s1 $zero exit_bubsort_for_2	# if !(j >= 0) , break
			
			sll $t1 $s1 2		# $t1 = j * 4
			addu $t1 $t1 $a0		# $t1 = v + j
			lw $t2 ($t1)		# $t2 = v[j]
			
			addi $t3 $t1 4		# $t3 = v + j + 1
			lw $t3 ($t3)		# $t3 = v[j + 1]

			ble $t2 $t3 exit_bubsort_for_2	# if !(v[j] > v[j + 1]) , break
			
			move $s2 $a1
			move $a1 $s1
				j swap
			call_swap_end:
			move $a1 $s2
			
			subi $s1 $s1 1		# j--
			j bubsort_for_2
		exit_bubsort_for_2:
		
		addi $s0 $s0 1	#i++
		j bubsort_for
	exit_bubsort_for:
	
	lw $ra 0($sp)		#load stack
	lw $a0 4($sp)		#
	lw $a1 8($sp)
	lw $s0 12($sp)
	lw $s1 16($sp)
	addi $sp $sp 20		#
	j call_bubsort_end
	

	
main:	
	li $t0 0
	sw $t0 0x3d40
	j import_number
	import_number_end:
	li $t0 0			# reset $t0
	
	#lw $t6 0x40000014	# load SysTick init
	
	la $ra call_bubsort_end
	move $a0 $sp		# $a0 = address
	li $a1 128		# $a1 = N
		j bubsort
	call_bubsort_end:
	
	lw $t7 0x40000014	# load SysTick last
	sub $t6 $t7 $t6		# t6 = Tick Count
	
	
	li $7 0xffff0000		# enable Timer
	sw $7 0x40000000
	li $7 3
	sw $7 0x40000008
	
	la $ra main_end
	main_end:		#
	jr $ra			# enable Interrupt

Interrupt:

sub $sp $sp 72
sw $1 0($sp)

li $27 0x9			# Disable Timer Interrupt
sw $27 0x40000008		# Clear TCON [2 : 1]

#sw $2 4($sp)
#sw $3 8($sp)
#sw $4 12($sp)
#sw $5 16($sp)
#sw $6 20($sp)
#sw $7 24($sp)
#sw $8 28($sp)
#sw $9 32($sp)
#sw $10 36($sp)
#sw $11 40($sp)
#sw $12 44($sp)
#sw $13 48($sp)
#sw $14 52($sp)
#sw $15 56($sp)
#sw $16 60($sp)
#sw $17 64($sp)
#sw $31 68($sp)

li $s0 0x3d40 		# base

lw $a0 ($s0)		# a0 = record
sll $a0 $a0 8		# a0 << 8

bne $a0 0  Exit_if	# if a0 == 0 a0 = 0xff
li $a0 0xff

Exit_if:			# else
sw $a0 ($s0)

addiu $1 $0 0xff
beq $a0 $1 case0
addiu $1 $0 0xff
sll $1 $1 8
beq $a0 $1 case1
lui $1 0xff
beq $a0 $1 case2
lui $1 0xff00
beq $a0 $1 case3

case0:
andi $a1 $t6 0xf
li $a2 0x100
j Exit_case
case1:
andi $a1 $t6 0xf0
srl $a1 $a1 4
li $a2 0x200
j Exit_case
case2:
andi $a1 $t6 0xf00
srl $a1 $a1 8
li $a2 0x400
j Exit_case
case3:
andi $a1 $t6 0xf000
srl $a1 $a1 12
li $a2 0x800
j Exit_case

Exit_case:

beq $a1 0x0 Display0
beq $a1 0x1 Display1
beq $a1 0x2 Display2
beq $a1 0x3 Display3
beq $a1 0x4 Display4
beq $a1 0x5 Display5
beq $a1 0x6 Display6
beq $a1 0x7 Display7
beq $a1 0x8 Display8
beq $a1 0x9 Display9
beq $a1 0xa Display10
beq $a1 0xb Display11
beq $a1 0xc Display12
beq $a1 0xd Display13
beq $a1 0xe Display14
beq $a1 0xf Display15

Display0:
li $1 63
j Exit_Display

Display1:
li $1 6
j Exit_Display

Display2:
li $1 91
j Exit_Display

Display3:
li $1 79
j Exit_Display

Display4:
li $1 102
j Exit_Display

Display5:
li $1 109
j Exit_Display

Display6:
li $1 125
j Exit_Display

Display7:
li $1 7
j Exit_Display

Display8:
li $1 127
j Exit_Display

Display9:
li $1 111
j Exit_Display

Display10:
li $1 119
j Exit_Display

Display11:
li $1 124
j Exit_Display

Display12:
li $1 57
j Exit_Display

Display13:
li $1 94
j Exit_Display

Display14:
li $1 121
j Exit_Display

Display15:
li $1 113
j Exit_Display

Exit_Display:
or $a2 $a2 $1


lui $2 0xffff		# construct 0xffffffff
srl $1 $2 16		#
or $2 $1 $2		# $2 = 0xffffffff

xor $a2 $a2 $2
sw $a2 0x40000010

#lw $2 4($sp)
#lw $3 8($sp)
#lw $4 12($sp)
#lw $5 16($sp)
#lw $6 20($sp)
#lw $7 24($sp)
#lw $8 28($sp)
#lw $9 32($sp)
#lw $10 36($sp)
#lw $11 40($sp)
#lw $12 44($sp)
#lw $13 48($sp)
#lw $14 52($sp)
#lw $15 56($sp)
#lw $16 60($sp)
#lw $17 64($sp)
#lw $31 68($sp)

li $27 0x00000003		# Enable Timer Interrupt
sw $27 0x40000008		# TCON[1] <= 1

lw $1 0($sp)
addi $sp $sp 72

jr $26

Exception:

import_number:
	
sub $sp $sp 512
li $t0 130
sw $t0 0($sp)
li $t0 114
sw $t0 4($sp)
li $t0 152
sw $t0 8($sp)
li $t0 113
sw $t0 12($sp)
li $t0 57
sw $t0 16($sp)
li $t0 29
sw $t0 20($sp)
li $t0 18
sw $t0 24($sp)
li $t0 21
sw $t0 28($sp)
li $t0 186
sw $t0 32($sp)
li $t0 111
sw $t0 36($sp)
li $t0 226
sw $t0 40($sp)
li $t0 131
sw $t0 44($sp)
li $t0 226
sw $t0 48($sp)
li $t0 149
sw $t0 52($sp)
li $t0 144
sw $t0 56($sp)
li $t0 232
sw $t0 60($sp)
li $t0 67
sw $t0 64($sp)
li $t0 242
sw $t0 68($sp)
li $t0 180
sw $t0 72($sp)
li $t0 5
sw $t0 76($sp)
li $t0 234
sw $t0 80($sp)
li $t0 77
sw $t0 84($sp)
li $t0 71
sw $t0 88($sp)
li $t0 18
sw $t0 92($sp)
li $t0 237
sw $t0 96($sp)
li $t0 207
sw $t0 100($sp)
li $t0 190
sw $t0 104($sp)
li $t0 53
sw $t0 108($sp)
li $t0 66
sw $t0 112($sp)
li $t0 175
sw $t0 116($sp)
li $t0 133
sw $t0 120($sp)
li $t0 124
sw $t0 124($sp)
li $t0 40
sw $t0 128($sp)
li $t0 177
sw $t0 132($sp)
li $t0 161
sw $t0 136($sp)
li $t0 162
sw $t0 140($sp)
li $t0 3
sw $t0 144($sp)
li $t0 167
sw $t0 148($sp)
li $t0 211
sw $t0 152($sp)
li $t0 96
sw $t0 156($sp)
li $t0 21
sw $t0 160($sp)
li $t0 10
sw $t0 164($sp)
li $t0 70
sw $t0 168($sp)
li $t0 113
sw $t0 172($sp)
li $t0 81
sw $t0 176($sp)
li $t0 68
sw $t0 180($sp)
li $t0 16
sw $t0 184($sp)
li $t0 240
sw $t0 188($sp)
li $t0 255
sw $t0 192($sp)
li $t0 156
sw $t0 196($sp)
li $t0 204
sw $t0 200($sp)
li $t0 51
sw $t0 204($sp)
li $t0 201
sw $t0 208($sp)
li $t0 182
sw $t0 212($sp)
li $t0 158
sw $t0 216($sp)
li $t0 91
sw $t0 220($sp)
li $t0 165
sw $t0 224($sp)
li $t0 155
sw $t0 228($sp)
li $t0 20
sw $t0 232($sp)
li $t0 32
sw $t0 236($sp)
li $t0 16
sw $t0 240($sp)
li $t0 191
sw $t0 244($sp)
li $t0 205
sw $t0 248($sp)
li $t0 126
sw $t0 252($sp)
li $t0 163
sw $t0 256($sp)
li $t0 156
sw $t0 260($sp)
li $t0 203
sw $t0 264($sp)
li $t0 55
sw $t0 268($sp)
li $t0 152
sw $t0 272($sp)
li $t0 179
sw $t0 276($sp)
li $t0 57
sw $t0 280($sp)
li $t0 36
sw $t0 284($sp)
li $t0 101
sw $t0 288($sp)
li $t0 247
sw $t0 292($sp)
li $t0 242
sw $t0 296($sp)
li $t0 216
sw $t0 300($sp)
li $t0 190
sw $t0 304($sp)
li $t0 69
sw $t0 308($sp)
li $t0 87
sw $t0 312($sp)
li $t0 169
sw $t0 316($sp)
li $t0 69
sw $t0 320($sp)
li $t0 251
sw $t0 324($sp)
li $t0 15
sw $t0 328($sp)
li $t0 172
sw $t0 332($sp)
li $t0 214
sw $t0 336($sp)
li $t0 188
sw $t0 340($sp)
li $t0 187
sw $t0 344($sp)
li $t0 193
sw $t0 348($sp)
li $t0 55
sw $t0 352($sp)
li $t0 64
sw $t0 356($sp)
li $t0 218
sw $t0 360($sp)
li $t0 64
sw $t0 364($sp)
li $t0 52
sw $t0 368($sp)
li $t0 158
sw $t0 372($sp)
li $t0 209
sw $t0 376($sp)
li $t0 140
sw $t0 380($sp)
li $t0 134
sw $t0 384($sp)
li $t0 63
sw $t0 388($sp)
li $t0 143
sw $t0 392($sp)
li $t0 250
sw $t0 396($sp)
li $t0 77
sw $t0 400($sp)
li $t0 113
sw $t0 404($sp)
li $t0 231
sw $t0 408($sp)
li $t0 201
sw $t0 412($sp)
li $t0 136
sw $t0 416($sp)
li $t0 238
sw $t0 420($sp)
li $t0 129
sw $t0 424($sp)
li $t0 242
sw $t0 428($sp)
li $t0 60
sw $t0 432($sp)
li $t0 208
sw $t0 436($sp)
li $t0 113
sw $t0 440($sp)
li $t0 11
sw $t0 444($sp)
li $t0 25
sw $t0 448($sp)
li $t0 194
sw $t0 452($sp)
li $t0 55
sw $t0 456($sp)
li $t0 106
sw $t0 460($sp)
li $t0 201
sw $t0 464($sp)
li $t0 107
sw $t0 468($sp)
li $t0 140
sw $t0 472($sp)
li $t0 72
sw $t0 476($sp)
li $t0 153
sw $t0 480($sp)
li $t0 190
sw $t0 484($sp)
li $t0 11
sw $t0 488($sp)
li $t0 165
sw $t0 492($sp)
li $t0 159
sw $t0 496($sp)
li $t0 240
sw $t0 500($sp)
li $t0 181
sw $t0 504($sp)
li $t0 32
sw $t0 508($sp)

j import_number_end
