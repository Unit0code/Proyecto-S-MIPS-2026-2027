# tests/test_zero.asm
# Instrucciones cubiertas: $zero
# Casos cubiertos: Escribir en $zero y comprobar que sigue en 0.
# Salida esperada: 0

.text
main:
    # Intentamos escribir en $zero
    addi $zero, $zero, 15
    
    # Imprimimos $zero sumándole 48 (para que salga el caracter '0')
    addi $a0, $zero, 48
    addi $v0, $zero, 11
    syscall
    
    # Fin
    addi $v0, $zero, 10
    syscall