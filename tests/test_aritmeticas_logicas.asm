# tests/test_aritmeticas_logicas.asm
# Instrucciones cubiertas: add, sub, and, or
# Casos cubiertos: 
# - add/sub: operandos positivos y al menos un operando negativo.
# - and/or: operandos con unos en los 16 bits altos.
# Salida esperada: Letras visibles (A, B, C, D, E, F, G, H)

.text
main:
    # --- ADD: Positivos (5 + 10 = 15) -> Imprime 'A' ---
    addi $t0, $zero, 5
    addi $t1, $zero, 10
    add $a0, $t0, $t1       # $a0 = 15
    addi $a0, $a0, 50       # 15 + 50 = 65 ('A')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10     # Salto de línea
    addi $v0, $zero, 11
    syscall

    # --- ADD: Con un negativo (-5 + 10 = 5) -> Imprime 'B' ---
    addi $t0, $zero, -5
    add $a0, $t0, $t1       # $a0 = 5
    addi $a0, $a0, 61       # 5 + 61 = 66 ('B')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- SUB: Positivos (20 - 15 = 5) -> Imprime 'C' ---
    addi $t0, $zero, 20
    addi $t1, $zero, 15
    sub $a0, $t0, $t1       # $a0 = 5
    addi $a0, $a0, 62       # 5 + 62 = 67 ('C')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- SUB: Con un negativo (10 - (-15) = 25) -> Imprime 'D' ---
    addi $t1, $zero, -15
    sub $a0, $t0, $t1       # $a0 = 25
    addi $a0, $a0, 43       # 25 + 43 = 68 ('D')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- AND: Unos en los 16 bits altos ---
    # 0xFFFF0000 & 0xF0F0F0F0 = 0xF0F00000
    # Para imprimir una letra, aislamos un pedacito y le sumamos algo.
    lui $t0, 0xFFFF
    lui $t1, 0xF0F0
    ori $t1, $t1, 0x0F0F
    and $a0, $t0, $t1       # $a0 = 0xF0F00000
    srl $a0, $a0, 24        # $a0 = 0xF0 (240)
    addi $a0, $a0, 65       # 240 + 65 = 305
    andi $a0, $a0, 0x7F     
    lui $t0, 0xFFFF
    lui $t1, 0xF0F0
    ori $t1, $t1, 0x0F0F
    and $a0, $t0, $t1
    srl $a0, $a0, 23        # $a0 = 0x1E (30)
    addi $a0, $a0, 39       # 30 + 39 = 69 ('E')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- OR: Unos en los 16 bits altos ---
    # 0xFFFF0000 | 0x0000FFFF = 0xFFFFFFFF
    # 0xFFFFFFFF >> 28 = 0xF (15). 15 + 55 = 70 ('F')
    lui $t0, 0xFFFF
    ori $t1, $zero, 0xFFFF
    or $a0, $t0, $t1
    srl $a0, $a0, 28        # $a0 = 15
    addi $a0, $a0, 55       # 15 + 55 = 70 ('F')
    addi $v0, $zero, 11
    syscall
    
    # --- Fin del programa ---
    addi $v0, $zero, 10
    syscall