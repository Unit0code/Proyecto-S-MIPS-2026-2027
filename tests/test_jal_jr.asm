# tests/test_jal_jr.asm
# Instrucciones cubiertas: j, jal, jr
# Casos cubiertos: Procedimiento no hoja, guardando $ra en pila y retornando.
# Salida esperada: A, B

.text
main:
    jal proc_A              # Llama al procedimiento A (guarda PC+4 en $ra)
    
    # Al volver de proc_A, imprimimos 'B' para confirmar que el retorno fue exitoso.
    addi $a0, $zero, 66     # 'B'
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10     # Salto de línea
    addi $v0, $zero, 11
    syscall

    j fin                   # Salta al final del programa

# --- PROCEDIMIENTO A (No hoja) ---
proc_A:
    # 1. Guardamos $ra en la pila (reservamos 4 bytes)
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # 2. Imprimimos 'A' para saber que entramos aquí
    addi $a0, $zero, 65     # 'A'
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10     # Salto de línea
    addi $v0, $zero, 11
    syscall

    # 3. Llamamos al procedimiento B (esto sobrescribe $ra)
    jal proc_B

    # 4. Restauramos $ra de la pila
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    # 5. Retornamos a main
    jr $ra

# --- PROCEDIMIENTO B (Hoja) ---
proc_B:
    # Imprime un punto y coma para indicar que B se ejecutó
    addi $a0, $zero, 59     # ';' (ASCII 59)
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10     # Salto de línea
    addi $v0, $zero, 11
    syscall

    # Retorna al procedimiento A
    jr $ra

# --- FIN DEL PROGRAMA ---
fin:
    addi $v0, $zero, 10
    syscall