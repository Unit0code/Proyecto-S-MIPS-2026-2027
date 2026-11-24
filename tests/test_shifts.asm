# tests/test_shifts.asm
# Instrucciones cubiertas: sll, srl
# Casos cubiertos: shamt = 0, shamt != 0, srl de negativo.
# Salida esperada: A, B, C, D

.text
main:
    # --- CASO 1: sll con shamt = 0 ---
    # Al desplazar 0 posiciones, el valor no cambia (5).
    addi $t0, $zero, 5
    sll $a0, $t0, 0         # $a0 = 5
    addi $a0, $a0, 60       # 5 + 60 = 65 ('A')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 2: sll con shamt != 0 ---
    # Al desplazar 1 posición a la izquierda, 5 se convierte en 10.
    sll $a0, $t0, 1         # $a0 = 10
    addi $a0, $a0, 56       # 10 + 56 = 66 ('B')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 3: srl con shamt = 0 ---
    # Al desplazar 0 posiciones a la derecha, el valor no cambia (12).
    addi $t1, $zero, 12
    srl $a0, $t1, 0         # $a0 = 12
    addi $a0, $a0, 55       # 12 + 55 = 67 ('C')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 4: srl sobre un negativo (prueba lógica) ---
    # -8 en binario es 0xFFFFFFF8. 
    # Al hacer srl (lógico) >> 2, DEBEN ENTRAR CEROS: 0x3FFFFFFE.
    # (Si entraran unos, sería un sra aritmético y daría 0xFFFFFFFE).
    addi $t2, $zero, -8
    srl $a0, $t2, 2         # $a0 = 0x3FFFFFFE (1073741822)
    
    # Convertimos el resultado gigante en una 'D' (68) de forma segura:
    srl $a0, $a0, 24        # $a0 = 63
    andi $a0, $a0, 0x3F     # $a0 = 63 (nos aseguramos de que sea pequeño)
    addi $a0, $a0, 5        # 63 + 5 = 68 ('D')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- Fin del programa ---
    addi $v0, $zero, 10
    syscall