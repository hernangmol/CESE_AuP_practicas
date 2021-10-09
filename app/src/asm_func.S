.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_sum
.global asm_svc
.global asm_zeros
.global asm_escalar32
.global asm_escalar16
.global asm_escalarSat12

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void c_zeros(uint32_t *vector, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: vector
@   r1: longitud
@
@ Valor de retorno:
@   nada
@
.thumb_func
    asm_zeros:
		mov r2,0
	.etiqueta:
		str r2,[r0],4
		subs r1,1
    	bne .etiqueta
    	bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_escalar32 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t indice, uint32_t factor);
@
@ Parametros recibidos:
@   r0: *Entrada
@   r1: *Resultado
@	r2: indice
@	r3: factor
@
.thumb_func
	asm_escalar32:
		push	{r4-r5}			@ Salvo los registros que no se guardan automaticamente (calling conv)
	.loopEj2:
		ldr		r5, [r0], 4		@ recorro el vector de entrada con r5
		mul		r4, r5, r3		@ cargo en r4 el producto de r5 y r3
		str		r4, [r1], 4		@ guardo el resultado en [r1] e incremento en 4
		subs	r2, 1			@ actualizo indice y flags
		bne		.loopEj2		@ vuelve a loopEj2 hasta r2 = 0
	pop		{r4-r5}				@ Repongo los registros no automáticos
	bx		lr					@ retorno al punto de llamada

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_escalar16 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t indice, uint32_t factor);
@
@ Parametros recibidos:
@   r0: *Entrada
@   r1: *Resultado
@	r2: indice
@	r3: factor
@
.thumb_func
	asm_escalar16:
		push	{r4-r5}			@ Salvo los registros que no se guardan automaticamente (calling conv)
	.loopEj3:
		ldrh	r5, [r0], 2		@ recorro el vector de entrada con r5
		mul		r4, r5, r3		@ cargo en r4 el producto de r5 y r3
		strh	r4, [r1], 2		@ guardo el resultado en [r1] e incremento en 4
		subs	r2, 1			@ actualizo indice y flags
		bne		.loopEj3		@ vuelve a loopEj2 hasta r2 = 0
	pop		{r4-r5}				@ Repongo los registros no automáticos
	bx		lr					@ retorno al punto de llamada

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_escalarSat16 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t indice, uint32_t factor);
@
@ Parametros recibidos:
@   r0: *Entrada
@   r1: *Resultado
@	r2: indice
@	r3: factor
@
.thumb_func
	asm_escalarSat12:
		push	{r4-r5}			@ Salvo los registros que no se guardan automaticamente (calling conv)
	.loopEj4:
		ldrh	r5, [r0], 2		@ recorro el vector de entrada con r5
		mul		r4, r5, r3		@ cargo en r4 el producto de r5 y r3
		usat 	r4, 12, r4		@ saturación
		strh	r4, [r1], 2		@ guardo el resultado en [r1] e incremento en 4
		subs	r2, 1			@ actualizo indice y flags
		bne		.loopEj4		@ vuelve a loopEj2 hasta r2 = 0
	pop		{r4-r5}				@ Repongo los registros no automáticos
	bx		lr					@ retorno al punto de llamada