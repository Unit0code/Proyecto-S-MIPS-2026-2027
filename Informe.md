# Nombre y VHDL

**Estudiante:** Marlon A. Rodríguez Gigato  
**Grupo:** C212  

**Entidad VHDL:** No se empleó ninguna entidad VHDL, ya que se consideró una complicación añadida en términos de tiempo y dependencia de software externo, sin aportar ventajas significativas para el alcance del proyecto.

---

## 2. Diagrama del DataPath

### Entradas y sus especificaciones

| Entradas (Inputs) | Sección en el diagrama | Características / Procedencia |
| :--- | :--- | :--- |
| MEM_RDATA | Entradas Placa | Palabra de 32 bits leída en la dirección MEM_ADDR |
| CLK | Entradas Placa | Reloj principal que sincroniza toda la placa |
| RESET | Entradas Placa | Reinicia al estado inicial todos los registros y estados |
| Enable_IR | Control Unit (señales de estado) | Habilita la escritura en el IR |
| Enable_PC | Control Unit (señales de estado) | Habilita la escritura en el PC |
| Enable_Result_ALU | Control Unit (señales de estado) | Habilita la escritura en el registro Result ALU |
| Enable_MDR | Control Unit (señales de estado) | Habilita la escritura en el MDR |
| Sel_Write_sel_RF | Control Unit (señales de estado) | Selector del selector de escritura del Register File |
| Sel_Data_RF | Control Unit (señales de estado) | Selector de la entrada de escritura del Register File |
| is_syscall | Control Unit (señales de estado) | Indica que la instrucción leída es un syscall |
| Sel_ALU_A | Control Unit (señales de estado) | Selector del operando A de la ALU |
| Sel_ALU_B | Control Unit (señales de estado) | Selector del operando B de la ALU |
| Sel_ALU_OP | Control Unit (señales de estado) | Selector de la operación (incluyendo ALU Op) de la ALU |
| Sel_PC_Prox | Control Unit (señales de estado) | Selector de la entrada de escritura del PC |
| Sel_Address | Control Unit (señales de estado) | Selector de la salida MEM_ADDR |
| ALU_Op | Entradas Instruction Decoder | Indica la operación a realizar en la ALU |
| Is_Byte | Entradas Instruction Decoder | Indica que la operación trabaja con bytes |
| Is_lbu | Entradas Instruction Decoder | Indica que la instrucción actual es lbu |
| ExtImm | Entradas Instruction Decoder | Selector del tipo de extensión del inmediato |

### Salidas y sus especificaciones

| Salidas (Outputs) | Destino | Características / Procedencia |
| :--- | :--- | :--- |
| MEM_ADDR | Placa | Dirección a la que se apunta en memoria |
| TTY_DATA | Placa | 7 bits en código ASCII para escribir en el TTY |
| MEM_WDATA | Placa | Palabra de 32 bits a escribir en la dirección ADDR |
| MEM_BE | Placa | Habilitador de escritura en los bytes respectivos en ADDR |
| Flag_zero | Control Unit | Señal de estado para la instrucción syscall |
| Op_IR | Instruction Decoder | Operación de la instrucción leída |
| funct_IR | Instruction Decoder | Campo funct de la instrucción leída |
| RS | Branch Control | Registro del Register File en la dirección RS |
| RT | Branch Control | Registro del Register File en la dirección RT |

### Componentes Internos

| Componente | Función |
| :--- | :--- |
| Register File | Almacena los datos de trabajo del procesador. Permite leer dos registros simultáneamente (para operar con ellos) y escribir un resultado en un registro destino en un mismo ciclo de reloj. |
| ALU (Unidad Aritmético-Lógica) | Componente central de cálculo. Realiza las operaciones ADD, SUB, OR, AND, SLL, SRL y SLT utilizando como operandos los datos del Register File, valores inmediatos, algunas constantes o el PC. |
| ResultALU | Almacena temporalmente el resultado que arroja la ALU. Este valor puede redirigirse para escribirse de vuelta en el Register File o utilizarse como dirección de memoria (MEM_ADDR). |
| MDR (Memory Data Register) | Almacena temporalmente los datos que se leen de la memoria antes de enviarlos al Register File. Sus entradas ya corresponden al byte extendido (con o sin signo) en caso de ser lbu o lb. |
| IR (Instruction Register) | Almacena la instrucción actual que se está ejecutando. De aquí se extraen los campos de la instrucción (opcode, rs, rt, funct, etc.) para decodificarla y controlar el datapath. |
| PC (Program Counter) | Almacena la dirección de la próxima instrucción a ejecutar. Se incrementa en 4 bytes. |
| Lógica combinacional del IMM (Extensión de Inmediatos) | Toma el valor inmediato de la instrucción (de 16 bits o menos) y lo expande a 32 bits, aplicando extensión con signo, con ceros, del tipo Lui o del tipo salto condicional → SgnExt(imm)*4 ← (estas dos últimas definidas por el autor) según el tipo de operación. |
| Extensión de shamt | Prepara y extiende el valor de "shamt" (cantidad de desplazamiento) contenido en la instrucción para ser utilizado en operaciones de desplazamiento de bits. |
| Selector de byte para LBU, LB (Lógica de carga de bytes) | Extrae el byte específico de un dato leído de memoria (de 32 bits) cuando se ejecuta una carga de byte. Aplica la extensión de signo (LB) o extensión con ceros (LBU) para entregar el dato correcto de 32 bits al registro MDR. |

### Decisiones de diseño

1. Reset asíncrono: todos los registros se inicializan a 0, exceptuando el primer estado Fetch de la FSM y los registros $gp y $sp.
2. El Register File no posee señal de Enable; se implementó de manera que, cuando no se desea escribir, basta con apuntar a la dirección $zero, donde no se puede escribir.

![DIAGRAMA](https://i.imgur.com/57YoCNf.png)

![DIAGRAMA](https://i.imgur.com/WzVXibT.png)

---

## 3. Tabla de Codificaciones de Estado de la FSM

La FSM posee 16 estados, cada uno representado como un registro individual para facilitar el proceso de depuración, dependientes de ciertas señales de estado provenientes del DataPath, el Instruction Decoder y el Branch Control. Es una máquina de Moore. El RESET hace todos los registros 0 exceptuando al registro (y estado inicial) FETCH. Para ello se implementó un registro especial con Latches de la forma Maestro-Esclavo, y con una entrada SET_1 en lugar de un Reset común.

| Estado | Codificación | Descripción |
| :--- | :--- | :--- |
| FETCH | 0000 | Búsqueda: Se lee la instrucción de la memoria (usando la dirección del PC) y se carga en el IR. Se actualiza el PC (PC + 4). |
| DECODE | 0001 | Decodificación: Se extraen los campos de la instrucción (opcode y funct) para tomar una decisión con respecto al próximo estado. |
| LOG_ARIT | 0010 | Operación Lógica/Aritmética: La ALU realiza operaciones tipo R (suma, resta, AND, OR, etc.) usando los registros leídos. |
| SHAMT | 0011 | Desplazamiento (Shift): Se ejecutan instrucciones de desplazamiento (sll, srl) usando el valor de shamt. |
| IMM | 0100 | Inmediato: Se realizan operaciones aritméticas/lógicas que involucran un valor inmediato extendido (addi, andi, etc.). |
| LUI | 0101 | Load Upper Immediate: Carga un valor inmediato en la parte alta (16 bits superiores) de un registro. |
| MEM | 0110 | Acceso a Memoria: Se calcula la dirección efectiva de memoria (sumando la base y el offset) para operaciones Load o Store. |
| LOAD_MDR | 0111 | Carga en MDR: Se lee el dato desde la memoria y se guarda temporalmente en el registro MDR. |
| LOAD_RF | 1000 | Escritura en Register File: El dato leído de la memoria se escribe en el registro destino del Register File. |
| STORE | 1001 | Almacenamiento: Se escribe el dato de un registro de la CPU en la dirección de memoria calculada. |
| BRANCH | 1010 | Salto Condicional: Si se cumple una condición (ej. beq, bne), se actualiza el PC con la dirección del salto. Depende del Branch Control. |
| JUMP | 1011 | Salto Incondicional: Se actualiza el PC con la dirección de salto especificada en la instrucción (j, jal). |
| JR | 1100 | Jump Register: Salto a la dirección almacenada en un registro. |
| SYSCALL10 | 1101 | Llamada al sistema 10: Estado especial para manejar la instrucción syscall con código 10. |
| SYSCALL11 | 1110 | Llamada al sistema 11: Estado especial para manejar la instrucción syscall con código 11 (impresión de caracteres). |
| FIN | 1111 | Fin: Estado final o de parada (halt), donde la CPU detiene su ejecución y la señal Halt se mantiene activa. |

### Transiciones y condiciones

| Estado | Condición | Transición |
| :--- | :--- | :--- |
| FETCH | Siempre (Incondicional) | -> DECODE |
| DECODE | Instruction Class = ALUR y is_shamt = 0 | -> LOG_ARIT |
| DECODE | Instruction Class = ALUR y is_shamt = 1 | -> SHAMT |
| DECODE | Instruction Class = ALUI y is_lui = 0 | -> IMM |
| DECODE | Instruction Class = ALUI y is_lui = 1 | -> LUI |
| DECODE | Instruction Class = MEMORY | -> MEM |
| DECODE | Instruction Class = BRANCH | -> BRANCH |
| DECODE | Instruction Class = JUMP | -> JUMP |
| DECODE | Instruction Class = JR | -> JR |
| DECODE | Instruction Class = SYSCALL | -> SYSCALL10 |
| DECODE | Instruction Class = ILEGAL | -> FIN |
| LOG_ARIT | Siempre (Incondicional) | -> FETCH |
| SHAMT | Siempre (Incondicional) | -> FETCH |
| IMM | Siempre (Incondicional) | -> FETCH |
| LUI | Siempre (Incondicional) | -> FETCH |
| MEM | Memory_write = 0 | -> LOAD_MDR |
| MEM | Memory_write = 1 | -> STORE |
| LOAD_MDR | Siempre (Incondicional) | -> LOAD_RF |
| LOAD_RF | Siempre (Incondicional) | -> FETCH |
| STORE | Siempre (Incondicional) | -> FETCH |
| BRANCH | Siempre (Incondicional) | -> FETCH |
| JUMP | Siempre (Incondicional) | -> FETCH |
| JR | Siempre (Incondicional) | -> FETCH |
| SYSCALL10 | Flag_Zero = 1 | -> FIN |
| SYSCALL10 | Flag_Zero = 0 | -> SYSCALL11 |
| SYSCALL11 | Siempre (Incondicional) | -> FETCH |
| FIN | Siempre (Incondicional) | -> FIN |

---

## 4. Valores de las señales de estado en cada estado

| Estado | MEM_WE (1b) | TTY_WE (1b) | HALT (1b) | sel_ALU_Op (1b) | sel_PC_prox (2b) | sel_ADDR (1b) | enable_IR (1b) | enable_PC (1b) | enable_MDR (1b) | enable_Result_ALU (1b) | sel_write_sel_RF (2b) | sel_data_RF (2b) | is_syscall (1b) | sel_ALU_A (2b) | sel_ALU_B (3b) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| FETCH | 0 | 0 | 0 | 1 | 00 | 0 | 1 | 1 | 0 | 0 | 00 | 00 | 0 | 01 | 011 |
| DECODE | 0 | 0 | 0 | 0 | 00 | 0 | 0 | 0 | 0 | 0 | 00 | 00 | 0 | 00 | 000 |
| LOG_ARIT | 0 | 0 | 0 | 0 | 00 | 0 | 0 | 0 | 0 | 0 | 01 | 00 | 0 | 00 | 000 |
| SHAMT | 0 | 0 | 0 | 0 | 00 | 0 | 0 | 0 | 0 | 0 | 01 | 00 | 0 | 10 | 010 |
| IMM | 0 | 0 | 0 | 0 | 00 | 0 | 0 | 0 | 0 | 0 | 10 | 00 | 0 | 00 | 001 |
| LUI | 0 | 0 | 0 | 0 | 00 | 0 | 0 | 0 | 0 | 0 | 10 | 11 | 0 | 00 | 000 |
| MEM | 0 | 0 | 0 | 1 | 00 | 0 | 0 | 0 | 0 | 1 | 00 | 00 | 0 | 00 | 001 |
| LOAD_MDR | 0 | 0 | 0 | 0 | 00 | 1 | 0 | 0 | 1 | 0 | 00 | 00 | 0 | 00 | 000 |
| LOAD_RF | 0 | 0 | 0 | 0 | 00 | 0 | 0 | 0 | 0 | 0 | 10 | 01 | 0 | 00 | 000 |
| STORE | 1 | 0 | 0 | 0 | 00 | 1 | 0 | 0 | 0 | 0 | 00 | 00 | 0 | 00 | 000 |
| BRANCH | 0 | 0 | 0 | 1 | 00/11 | 0 | 0 | 1/0 | 0 | 0 | 00 | 00 | 0 | 01 | 001 |
| JUMP | 0 | 0 | 0 | 0 | 01 | 0 | 0 | 1 | 0 | 0 | 00/10 | 01/10 | 0 | 00 | 000 |
| JR | 0 | 0 | 0 | 0 | 10 | 0 | 0 | 1 | 0 | 0 | 00 | 00 | 0 | 00 | 000 |
| SYSCALL10 | 0 | 0 | 0 | 0 | 00 | 0 | 0 | 0 | 0 | 0 | 00 | 00 | 1 | 00 | 100 |
| SYSCALL11 | 0 | 0/1 | 0 | 0 | 00 | 0 | 0 | 0 | 0 | 0 | 00 | 00 | 1 | 00 | 101 |
| FIN | 0 | 0 | 1 | 0 | 00 | 0 | 0 | 0 | 0 | 0 | 00 | 00 | 0 | 00 | 000 |

---

## 5. Codificación de las Operaciones de la ALU

| Operación | Codificación (3 bits) | Descripción |
| :--- | :--- | :--- |
| ADD | 000 | Suma aritmética (A + B) |
| SUB | 001 | Resta aritmética (A - B) |
| AND | 010 | Compuerta lógica AND bit a bit (A & B) |
| OR | 011 | Compuerta lógica OR bit a bit (A \| B) |
| SLT | 100 | Set Less Than (si A < B, resultado = 1; si no, 0) |
| SLL | 101 | Shift Left Logical (Desplazamiento lógico a la izquierda) |
| SRL | 110 | Shift Right Logical (Desplazamiento lógico a la derecha) |

---

## 6. Salidas del Instruction Decoder

| Señal de Salida | Ancho (bits) | Descripción |
| :--- | :--- | :--- |
| Instruction_Class | 3 | Código que indica la clase general de la instrucción (ALUR, ALUI, MEMORY, BRANCH, JUMP, JR, SYSCALL, ILEGAL) para guiar la máquina de estados. |
| ALU_Op | 3 | Código de operación específico para la ALU (ADD, SUB, AND, OR, SLT, SLL, SRL). |
| Ext_type_imm | 2 | Indica cómo debe extenderse el valor inmediato (00: extensión de signo, 01: extensión con ceros, 10: para LUI, 11: Offset). |
| Memory_write | 1 | Señal de control que indica si la instrucción actual es de escritura en memoria (1 para sw/sb, 0 para el resto). |
| Is_Byte | 1 | Indica si la operación de memoria es a nivel de byte (1 para lb, lbu, sb; 0 para lw, sw). |
| Is_lbu | 1 | Indica si la instrucción es un Load Byte Unsigned (lbu), para habilitar la extensión con ceros en el datapath. |
| Is_jal | 1 | Indica si la instrucción es un Jump And Link (jal), para guardar la dirección de retorno (PC+4) en el registro $ra. |
| Is_lui | 1 | Indica si la instrucción es Load Upper Immediate (lui), para colocar el inmediato en los 16 bits superiores. |
| Is_beq | 1 | Indica si la instrucción es un Branch on Equal (beq), para evaluar la condición de salto correspondiente. |
| Is_shamt | 1 | Indica si la instrucción utiliza el campo de desplazamiento (shamt). Se activa si es una instrucción sll o srl. |

---

## 7. Ciclos por instrucción

| Instrucción | Clase | Ciclos |
| :--- | :--- | :--- |
| add | ALUR | 3 |
| sub | ALUR | 3 |
| and | ALUR | 3 |
| or | ALUR | 3 |
| slt | ALUR | 3 |
| sll | ALUR (shamt) | 3 |
| srl | ALUR (shamt) | 3 |
| addi | ALUI | 3 |
| slti | ALUI | 3 |
| andi | ALUI | 3 |
| ori | ALUI | 3 |
| lui | ALUI (lui) | 3 |
| lw | MEMORY (Load) | 5 |
| sw | MEMORY (Store) | 4 |
| lb | MEMORY (Load) | 5 |
| lbu | MEMORY (Load) | 5 |
| sb | MEMORY (Store) | 4 |
| beq | BRANCH | 3 |
| bne | BRANCH | 3 |
| j | JUMP | 3 |
| jal | JUMP | 3 |
| jr | JR | 3 |
| syscall | SYSCALL | 3 - 4 |

---

## 8. Tabla de Cobertura de los tests

* Las instrucciones SYSCALL 11 y 10 se emplean en todos los programas de prueba.

| Instrucciones | Casos cubiertos | Archivo |
| :--- | :--- | :--- |
| add, sub | Con operandos positivos y con al menos un operando negativo. | test_add_sub.asm |
| and, or | Con operandos que tengan unos en los 16 bits altos. | test_logicas.asm |
| slt, slti | Un caso con resultado 1 y otro con 0; al menos uno con operando negativo. | test_slt.asm |
| sll, srl | Con shamt = 0 y shamt ≠ 0; srl sobre un valor negativo. | test_shifts.asm |
| addi, addiu, addu | Con un inmediato negativo y mediante las pseudoinstrucciones li (constante entre −2^15 y 2^15−1) y move. | test_inmediatos.asm |
| andi, ori, lui | Con un inmediato cuyo bit 15 vale 1 (debe extenderse con ceros). | test_inmediatos_logicos.asm |
| lw, sw | Con desplazamiento positivo y con desplazamiento negativo. | test_memoria_lw_sw.asm |
| lb, lbu | Sobre un byte cuyo bit 7 vale 1, en al menos dos posiciones distintas dentro de la palabra. | test_memoria_bytes.asm |
| sb | En las cuatro posiciones de una misma palabra, comprobando después con lw que los otros bytes no cambiaron. | test_sb.asm |
| beq, bne | Cada uno tomado y no tomado; al menos un salto hacia atrás. | test_saltos.asm |
| j, jal, jr | Un procedimiento que llama a otro (no hoja), guardando $ra en la pila y retornando correctamente. | test_jal_jr.asm |
| $zero | Una instrucción que escribe en $zero, comprobando después que sigue valiendo 0. | test_zero.asm |
| -- | Test genérico probando todas las instrucciones | test_generico.asm |

---

## 9. Resultados obtenidos con run_test.py

* Ejecutando 8 programas en la placa...
* OK programs\arithmetic.asm (5401 ciclos)
* OK programs\array_sum.asm (779 ciclos)
* OK programs\branches.asm (805 ciclos)
* OK programs\gcd.asm (2410 ciclos)
* OK programs\hello.asm (269 ciclos)
* **FALLO** programs\memory.asm (4151 ciclos)
  > detenido=true (MEM_ADDR final 0x000000d8)  
  > esperado (MARS):  
  > `00001800 00003ffc 8070f00d 0000000d 00000080`  
  > `ffffff80 00000070 ffffffe9 000000e9 807fe911`  
  > `ddccbbaa 12ff5678 00002000 00002008 00003ffc`  
  > obtenido (TTY):  
  > `00001800 00003ffc 8070f00d 0000000d 00000080`  
  > `ffffff80 00000070 ffffffe9 000000e9 807fe911`  
  > `000000aa 12ff5678 00002000 00002008 00003ffc`
* OK programs\multiply.asm (1667 ciclos)
* OK tests\test_add_sub.asm (116 ciclos)
* OK tests\test_generico.asm (149 ciclos)
* OK tests\test_inmediatos.asm (99 ciclos)
* OK tests\test_jal_jr.asm (96 ciclos)
* OK tests\test_logicas.asm (76 ciclos)
* OK tests\test_memoria_bytes.asm (132 ciclos)
* OK tests\test_memoria_lw_sw.asm (67 ciclos)
* OK tests\test_saltos.asm (158 ciclos)
* OK tests\test_sb.asm (65 ciclos)
* OK tests\test_shifts.asm (113 ciclos)
* OK tests\test_slt.asm (113 ciclos)
* OK tests\test_zero.asm (19 ciclos)

**18/19 correctos**

### 9.1 Limitantes conocidas

* Fallo al ejecutar `memory.asm`: falla en exactamente una de las salidas hexadecimales.
* Accesos no alineados, desbordamiento aritmético y accesos fuera de los 16 KiB (las direcciones se repiten cada 16 KiB).
* Se halló un error en el tester: los caracteres del 0 al 31 en ASCII son caracteres de control o invisibles. MARS los trata de una forma y el TTY de Logisim de otra (exceptuando el salto de línea, código 10), o al menos a mí me causaron error a la hora de hacer las comparaciones con la herramienta `run_tests.py`. Por ello, excluí la posibilidad de que se imprimieran dichos caracteres para evitar errores.