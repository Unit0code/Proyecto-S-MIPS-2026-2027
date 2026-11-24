# tests/test_logicas.asm
# Instrucciones cubiertas: and, or
# Casos cubiertos: Operandos con unos en los 16 bits altos.
# Salida esperada: A (para el AND), B (para el OR)

.text
main:
    # --- AND: Unos en los 16 bits altos ---
    # Operamos con: 0xFFFF0000 & 0xF0F0F0F0 = 0xF0F00000
    lui $t0, 0xFFFF         # $t0 = 0xFFFF0000 (bits altos en 1)
    lui $t1, 0xF0F0         # $t1 = 0xF0F00000
    
    and $t2, $t0, $t1       # $t2 = 0xF0F00000 Probamos los bits altos
    
    # Ahora, en lugar de operar con $t2 directamente,
    # lo desplazamos a la derecha para hacerlo pequeño.
    srl $a0, $t2, 24        # $a0 = 0x000000F0 (240)
    andi $a0, $a0, 0x3F     # $a0 = 48
    addi $a0, $a0, 17       # 48 + 17 = 65 ('A')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10     # Salto de línea
    addi $v0, $zero, 11
    syscall

    # --- OR: Unos en los 16 bits altos ---
    # Operamos con: 0xFFFF0000 | 0x0000FFFF = 0xFFFFFFFF
    lui $t0, 0xFFFF         # $t0 = 0xFFFF0000
    ori $t1, $zero, 0xFFFF  # $t1 = 0x0000FFFF
    
    or $t2, $t0, $t1        # $t2 = 0xFFFFFFFF Probamos los bits altos
    
    # Lo desplazamos para que quede pequeño y seguro
    srl $a0, $t2, 28        # $a0 = 0x0000000F (15)
    andi $a0, $a0, 0x3F     # $a0 = 15
    addi $a0, $a0, 51       # 15 + 51 = 66 ('B')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- Fin del programa ---
    addi $v0, $zero, 10
    syscall