.data 
a: .word   0
b: .word   0
c: .word   0
result_1: .word   0
result_2: .word   0
result_3: .word   0

.text

#a=10
li $t0, 10
sw $t0, a
#b=11
li $t0, 11
sw $t0, b
#c=0
li $t0, 0
sw $t0, c
lw $t1, b
lw $t0, a

# conditional statement:
bgt $t0, $t1 ,jmplabel_1

#a+100
lw $t0, a
li $t1, 100
add $t0, $t0, $t1
sw $t0, result_1



li $v0, 1
lw $a0, result_1
syscall 

jmplabel_1:
lw $t1, c
lw $t0, a

# conditional statement:
blt $t0, $t1 ,jmplabel_2

#a+200
lw $t0, a
li $t1, 200
add $t0, $t0, $t1
sw $t0, result_2



li $v0, 1
lw $a0, result_2
syscall 

jmplabel_2:
lw $t1, b
lw $t0, a

# conditional statement:
bne $t0, $t1 ,jmplabel_3

#a+100
lw $t0, a
li $t1, 100
add $t0, $t0, $t1
sw $t0, result_3



li $v0, 1
lw $a0, result_3
syscall 

jmplabel_3:
