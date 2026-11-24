# tests/test_basico.asm
# Prueba mínima de add, sub y syscall 11/10 sin instrucciones complejas.
# No usa li con números grandes, ni lui, ni saltos.

.text
main:
    # 1. Imprimir el caracter '9' (ASCII 57)
    # En lugar de li $t0, 5 + add, vamos directo al grano
    li $a0, 57
    li $v0, 11
    syscall

    # 2. Imprimir un salto de línea
    li $a0, 10
    li $v0, 11
    syscall

    # 3. Usar add con números pequeños (1 + 2 = 3, ASCII '3' = 51)
    li $t0, 1
    li $t1, 2
    add $a0, $t0, $t1
    addi $a0, $a0, 48
    li $v0, 11
    syscall

    # 4. Salto de línea
    li $a0, 10
    li $v0, 11
    syscall

    # 5. Usar sub con números pequeños (5 - 2 = 3, ASCII '3' = 51)
    li $t0, 5
    li $t1, 2
    sub $a0, $t0, $t1
    addi $a0, $a0, 48
    li $v0, 11
    syscall

    # 6. Salto de línea
    li $a0, 10
    li $v0, 11
    syscall

    # 7. Terminar
    li $v0, 10
    syscall