# tests/test_saltos.asm
# Instrucciones cubiertas: beq, bne
# Casos cubiertos: beq (tomado y no tomado), bne (tomado y no tomado), salto hacia atrás.
# Salida esperada: A, B, C, D

.text
main:
    addi $t0, $zero, 0      # Contador para el bucle

    # --- CASO 1: beq NO tomado ---
    # 1 == 2 (Falso), así que no salta y sigue de largo.
    addi $t1, $zero, 1
    addi $t2, $zero, 2
    beq $t1, $t2, fallo1    # NO tomado
    j ok1
fallo1:
    addi $a0, $zero, 88     # Imprime 'X' si falla
    addi $v0, $zero, 11
    syscall
ok1:
    addi $a0, $zero, 65     # 'A' (Éxito)
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 2: beq TOMADO ---
    # 3 == 3 (Verdadero), así que salta a la etiqueta.
    addi $t1, $zero, 3
    addi $t2, $zero, 3
    beq $t1, $t2, exito2
    j fallo2
exito2:
    addi $a0, $zero, 66     # 'B' (Éxito)
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall
    j fin_caso2
fallo2:
    addi $a0, $zero, 88     # 'X'
    addi $v0, $zero, 11
    syscall
fin_caso2:

    # --- CASO 3: bne NO tomado ---
    # 5 != 5 (Falso), así que no salta.
    addi $t1, $zero, 5
    addi $t2, $zero, 5
    bne $t1, $t2, fallo3    # NO tomado
    j ok3
fallo3:
    addi $a0, $zero, 88     # 'X'
    addi $v0, $zero, 11
    syscall
ok3:
    addi $a0, $zero, 67     # 'C' (Éxito)
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- CASO 4: bne TOMADO + salto hacia atrás ---
    # Haremos un bucle que salta hacia atrás 2 veces.
    # Usamos $t0 como contador.
    addi $t0, $zero, 0
bucle_atras:
    addi $t0, $t0, 1        # Incrementamos contador
    bne $t0, $t2, bucle_atras # Si contador != 5, salta hacia atrás
    
    # Si llega aquí, el bucle terminó.
    addi $a0, $zero, 68     # 'D' (Éxito)
    addi $v0, $zero, 11
    syscall
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall

    # --- Fin del programa ---
    addi $v0, $zero, 10
    syscall