# tests/test_add_sub.asm
# Instrucciones cubiertas: add, sub
# Casos cubiertos: Operandos positivos y al menos un operando negativo.
# Salida esperada: 
# A (para 5 + 10 = 15)
# B (para -5 + 10 = 5)
# C (para 20 - 15 = 5)
# D (para 10 - (-15) = 25)

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

    # --- Fin del programa ---
    addi $v0, $zero, 10
    syscall