# tests/test_inmediatos_logicos.asm
# Instrucciones cubiertas: andi, ori, lui
# Casos cubiertos: inmediato con bit 15 = 1 (extensión con ceros para andi/ori, y carga para lui).
# Salida esperada: A, B, C

.text
main:
    # --- CASO 1: andi con bit 15 = 1 ---
    # Inmediato 0x8000. Al extenderse con ceros, queda 0x00008000.
    # Si se extendiera con signo, quedaría 0xFFFF8000 y el AND daría otra cosa.
    addi $t0, $zero, -1     # $t0 = 0xFFFFFFFF
    andi $a0, $t0, 0x8000   # $a0 = 0x00008000 (32768)
    
    # Convertimos a 'A' (65) de forma segura:
    srl $a0, $a0, 7         # $a0 = 0x00000100 (256)
    andi $a0, $a0, 0x3F     # $a0 = 0
    addi $a0, $a0, 65       # 0 + 65 = 65 ('A')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 2: ori con bit 15 = 1 ---
    # Inmediato 0x8000. Al extenderse con ceros, queda 0x00008000.
    # Si se extendiera con signo, el OR metería unos en los 16 bits altos.
    addi $t1, $zero, 1
    ori $a0, $t1, 0x8000    # $a0 = 0x00008001 (32769)
    
    # Convertimos a 'B' (66) de forma segura:
    srl $a0, $a0, 8         # $a0 = 0x00000080 (128)
    andi $a0, $a0, 0x3F     # $a0 = 0
    addi $a0, $a0, 66       # 0 + 66 = 66 ('B')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 3: lui con bit 15 = 1 ---
    # Cargamos 0x8000 en la parte alta. El resultado debe ser 0x80000000.
    lui $a0, 0x8000         # $a0 = 0x80000000
    
    # Convertimos a 'C' (67) de forma segura:
    srl $a0, $a0, 24        # $a0 = 0x00000080 (128)
    andi $a0, $a0, 0x3F     # $a0 = 0
    addi $a0, $a0, 67       # 0 + 67 = 67 ('C')
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- Fin del programa ---
    addi $v0, $zero, 10
    syscall