# tests/test_memoria_lw_sw.asm
# Instrucciones cubiertas: lw, sw
# Casos cubiertos: desplazamiento positivo y desplazamiento negativo.
# Salida esperada: A, B

.text
main:
    # Cargamos la dirección base (usamos una zona de datos libre, ej: 0x2000)
    li $t0, 0x2000

    # --- CASO 1: sw y lw con desplazamiento positivo ---
    li $t1, 65              # Queremos imprimir 'A' (65)
    sw $t1, 4($t0)          # Guardamos 65 en 0x2004 (offset +4)
    
    lw $a0, 4($t0)          # Leemos de 0x2004
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10     # Salto de línea
    addi $v0, $zero, 11
    syscall

    # --- CASO 2: sw y lw con desplazamiento negativo ---
    # La base está en 0x2000. El offset es -4, así que accedemos a 0x1FFC.
    li $t2, 66              # Queremos imprimir 'B' (66)
    sw $t2, -4($t0)         # Guardamos 66 en 0x1FFC (offset -4)
    
    lw $a0, -4($t0)         # Leemos de 0x1FFC
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- Fin del programa ---
    addi $v0, $zero, 10
    syscall