# tests/test_generico.asm
# Instrucciones cubiertas: add, sub, and, or, lw, sw, beq, j
# Casos cubiertos: Un poco de todo.
# Salida esperada: A, B, C, D

.text
main:
    # --- 1. Aritmética y Lógica ---
    addi $t0, $zero, 10
    addi $t1, $zero, 5
    add $t2, $t0, $t1       # 10 + 5 = 15
    sub $t3, $t0, $t1       # 10 - 5 = 5
    and $t4, $t0, $t1       # 10 & 5 = 0 (1010 & 0101 = 0000)
    or  $t5, $t0, $t1       # 10 | 5 = 15 (1010 | 0101 = 1111)

    # --- 2. Memoria ---
    li $t6, 0x2000          # Dirección base
    sw $t2, 0($t6)          # Guardamos 15 en memoria
    lw $t7, 0($t6)          # Leemos 15 de memoria

    # Si todo funcionó, $t7 = 15. Lo convertimos en 'A' (65) e imprimimos.
    addi $a0, $t7, 50       # 15 + 50 = 65 ('A')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- 3. Saltos ---
    # Comparamos $t3 (5) con $t1 (5). Deberían ser iguales.
    beq $t3, $t1, son_iguales
    
    # Si NO son iguales, imprime 'X' (error)
    addi $a0, $zero, 88
    addi $v0, $zero, 11
    syscall
    j fin

son_iguales:
    # Si son iguales, imprime 'B'
    addi $a0, $zero, 66
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- 4. Bucle con contador ---
    # Sumamos 1 tres veces y luego comprobamos.
    addi $t0, $zero, 0
    addi $t1, $zero, 3
loop:
    addi $t0, $t0, 1
    beq $t0, $t1, salir_loop
    j loop

salir_loop:
    # Si el bucle funcionó, $t0 debe ser 3. Imprimimos 'C'.
    addi $a0, $zero, 67
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- 5. Imprimir 'D' final ---
    addi $a0, $zero, 68
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

fin:
    # --- Fin del programa ---
    addi $v0, $zero, 10
    syscall