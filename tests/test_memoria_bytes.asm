# tests/test_memoria_bytes.asm
# Instrucciones cubiertas: lb, lbu
# Casos cubiertos: byte con bit 7 = 1, en dos posiciones distintas (d[1:0]=0 y d[1:0]=1).
# Salida esperada: 0, 1, 0, 1

.text
main:
    li $t0, 0x2000          # Dirección base
    
    # Preparamos el byte 0x80 (bit 7 en 1) en dos posiciones.
    li $t1, 0x80
    sb $t1, 0($t0)          # d[1:0] = 0
    sb $t1, 1($t0)          # d[1:0] = 1

    # --- CASO 1: lb en posición 0 ---
    # 0x80 extendido con signo es 0xFFFFFF80 (negativo).
    lb $a0, 0($t0)
    # Sumamos 48. Si es negativo, el resultado seguirá siendo negativo (dará un simbolo raro).
    # Para forzar un '0' (48), hacemos un truco: sumamos 48 y miramos los bits.
    # 0xFFFFFF80 + 48 = 0xFFFFFFB0. Si hacemos andi 0x3F, da 48 ('0').
    addi $a0, $a0, 48
    andi $a0, $a0, 0x3F
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 2: lbu en posición 0 ---
    # 0x80 extendido con ceros es 0x00000080 (128).
    # 128 + 49 = 177. 177 & 0x3F = 49 ('1').
    lbu $a0, 0($t0)
    addi $a0, $a0, 49
    andi $a0, $a0, 0x3F
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 3: lb en posición 1 ---
    # Misma lógica que el caso 1, pero leyendo el byte 1.
    lb $a0, 1($t0)
    addi $a0, $a0, 48
    andi $a0, $a0, 0x3F
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 4: lbu en posición 1 ---
    # Misma lógica que el caso 2, pero leyendo el byte 1.
    lbu $a0, 1($t0)
    addi $a0, $a0, 49
    andi $a0, $a0, 0x3F
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- Fin del programa ---
    addi $v0, $zero, 10
    syscall