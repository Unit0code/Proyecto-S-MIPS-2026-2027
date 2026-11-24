# tests/test_slt.asm
# Instrucciones cubiertas: slt, slti
# Casos cubiertos: Resultado 1 y 0; operando negativo (comparación con/sin signo distinta).
# Salida esperada: 1, 0, 1, 0 (cada uno en una línea)

.text
main:
    # --- CASO 1: slt con resultado 1 (positivos) ---
    # 5 < 10 -> 1
    addi $t0, $zero, 5
    addi $t1, $zero, 10
    slt $a0, $t0, $t1       # $a0 = 1
    addi $a0, $a0, 48       # 1 + 48 = 49 ('1')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10     # Salto de línea
    addi $v0, $zero, 11
    syscall

    # --- CASO 2: slt con resultado 0 (positivos) ---
    # 10 < 5 -> 0
    slt $a0, $t1, $t0       # $a0 = 0
    addi $a0, $a0, 48       # 0 + 48 = 48 ('0')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 3: slt con operando negativo (signo vs sin signo) ---
    # -1 < 1 -> 1.
    addi $t2, $zero, -1     # $t2 = 0xFFFFFFFF
    addi $t3, $zero, 1
    slt $a0, $t2, $t3       # -1 < 1 -> 1
    addi $a0, $a0, 48       # 1 + 48 = 49 ('1')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 4: slti con resultado 0 (inmediato negativo) ---
    # 3 < -2 -> 0
    addi $t4, $zero, 3
    slti $a0, $t4, -2       # 3 < -2 -> 0
    addi $a0, $a0, 48       # 0 + 48 = 48 ('0')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- Fin del programa ---
    addi $v0, $zero, 10
    syscall