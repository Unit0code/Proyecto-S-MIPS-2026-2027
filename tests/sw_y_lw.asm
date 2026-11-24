.text
main:
    lui  $t0, 0xABCD
    ori  $t0, $t0, 0x1234   # $t0 = 0xABCD1234
    lui  $s0, 0x0000
    ori  $s0, $s0, 0x2000   # $s0 = 0x00002000 (dentro de tu RAM)

    sw   $t0, 0($s0)        # Guarda en 0x2000
    lw   $t1, 0($s0)        # Lee de 0x2000
    
    beq  $t0, $t1, ok
    addi $a0, $zero, 88     # 'X'
    j    print
ok: addi $a0, $zero, 79     # 'O'
print:
    addi $v0, $zero, 11
    syscall
    addi $v0, $zero, 10
    syscall