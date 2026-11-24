.text
main:
    lui  $s0, 0x0000
    ori  $s0, $s0, 0x2000   # $s0 = 0x2000
    lui  $t0, 0x1234
    ori  $t0, $t0, 0x5678   # $t0 = 0x12345678
    sw   $t0, 0($s0)        # Guarda palabra

    lb   $t1, 3($s0)        # Lee byte en 0x2003 (el 0x12 en little-endian)
    
    addi $t2, $zero, 0x12   # Esperamos 0x12
    beq  $t1, $t2, ok
    addi $a0, $zero, 88     # 'X'
    j    print
ok: addi $a0, $zero, 79     # 'O'
print:
    addi $v0, $zero, 11
    syscall
    addi $v0, $zero, 10
    syscall