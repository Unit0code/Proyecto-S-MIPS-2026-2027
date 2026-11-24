.text
main:
    lui  $s0, 0x0000
    ori  $s0, $s0, 0x2000   # $s0 = 0x2000
    addi $t0, $zero, 0xF0
    sb   $t0, 0($s0)        # Guarda 0xF0

    lbu  $t1, 0($s0)        # Lee sin signo
    
    addi $t2, $zero, 0xF0   # Esperamos 0x000000F0
    beq  $t1, $t2, ok
    addi $a0, $zero, 88     # 'X'
    j    print
ok: addi $a0, $zero, 79     # 'O'
print:
    addi $v0, $zero, 11
    syscall
    addi $v0, $zero, 10
    syscall