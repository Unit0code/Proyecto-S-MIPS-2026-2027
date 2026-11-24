# tests/test_sb.asm
# Instrucciones cubiertas: sb, lw
# Casos cubiertos: sb en las 4 posiciones (d[1:0]=0,1,2,3) y comprobación con lw.
# Salida esperada: A

.text
main:
    li $t0, 0x2000          # Dirección base

    # --- Preparamos los bytes ---
    # Queremos formar la palabra 0x44434241 ('A'=0x41, 'B'=0x42, 'C'=0x43, 'D'=0x44)
    li $t1, 0x41            # Byte para pos 0
    li $t2, 0x42            # Byte para pos 1
    li $t3, 0x43            # Byte para pos 2
    li $t4, 0x44            # Byte para pos 3

    # --- Escribimos en las 4 posiciones ---
    sb $t1, 0($t0)          # d[1:0] = 0
    sb $t2, 1($t0)          # d[1:0] = 1
    sb $t3, 2($t0)          # d[1:0] = 2
    sb $t4, 3($t0)          # d[1:0] = 3

    # --- Comprobación con lw ---
    # Leemos la palabra completa. En Little Endian, debería ser 0x44434241.
    lw $a0, 0($t0)          # $a0 = 0x44434241

    # Para imprimir una 'A' (65) de forma segura:
    # 0x44434241 & 0x3F = 1. 1 + 64 = 65 ('A')
    andi $a0, $a0, 0x3F     # $a0 = 0x00000001 (1)
    addi $a0, $a0, 64       # 1 + 64 = 65 ('A')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10     # Salto de línea
    addi $v0, $zero, 11
    syscall

    # --- Fin del programa ---
    addi $v0, $zero, 10
    syscall