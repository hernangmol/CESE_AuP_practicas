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
.global asm_filtroVentana
.global asm_pack16
.global asm_posMax
.global asm_invertir

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
@ void asm_escalarSat12 (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t indice, uint32_t factor);
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

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_filtroVentana (uint32_t * vectorIn, uint32_t * vectorOut, uint32_t ventana, uint32_t);
@
@ Parametros recibidos:
@   r0: *Entrada
@   r1: *Resultado
@	r2: Ventana
@
.thumb_func
	asm_filtroVentana:
		push	{r4-r9}			@ Salvo los registros que voy a utilizar: R4-> contador
		mov 	r3, 1000		@ R5 -> acumulador, R6-> dir del valor a sumar, R7-> dir del valor a restar
		mov 	r9, r2						
	.prepEj5:
		ldr		r4, [r0], 4		@ recorro el vector de entrada con r4
		add		r5, r4	 		@ sumo r4 al acumulador
		sub 	r3, 1			
		subs	r2, 1			@ chequeo si ya se agoto la ventana
		bne		.prepEj5		@ 
		udiv 	r8, r5, r9		@ sume los diez primeros valores, ahora divido por 10
		str		r8, [r1], 4 	@ y guardo en la primer posición de salida
	.loopEj5:
		ldr		r4, [r0], 4		@ igual que en el 1er loop, cargo el valor a sumar (i - esimo)
		add		r5, r4			@ sumo al acumulador
		ldr		r4, [r0 , -44]	@ cargo el valor a restar (i-10 esimo)
		sub		r5, r4			@ resto al acumulador
		udiv 	r8, r5, r9		@ calculo la media
		str		r8, [r1], 4		@ escribo en el vector de salida
		subs	r3, 1
		bne		.loopEj5 
	pop		{r4-r9}				@ Repongo los registros no automáticos
	bx		lr					@ retorno al punto de llamada

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_packet16 (int32_t * vectorIn, int16_t * vectorOut, uint32_t longitud);
@
@ Parametros recibidos:
@   r0: *Entrada
@   r1: *Salida
@	r2: longitud
@
.thumb_func
	asm_pack16:
		add r0, 2	
	.loopEj6:
		ldrh	r3, [r0], 4		@ recorro el vector de entrada con r3
		strh	r3, [r1], 2		@ guardo el resultado en [r1] e incremento en 2
		subs	r2, 1			@ decremento contador
		bne		.loopEj6		@ vuelve a loopEj6 hasta que r2 = 0
	bx		lr					@ retorno al punto de llamada

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_posMax (uint32_t * vectorIn, uint32_t largo);
@
@ Parametros recibidos:
@   r0: *Entrada
@   r1: largo del vector
@
.thumb_func
	asm_posMax:
		push	{r4-r5}			@ Salvo los registros que no se guardan automaticamente (calling conv)
		ldr		r3, [r0]		@ r3 almacena el maximo, se carga con el primer valor
		mov 	r4, 0			@ r4 recorre el vector de modo creciente
	.loopEj7:
		ldr		r2, [r0], 4		@ recorro el vector de entrada con r2
		cmp		r2, r3 			@ r3 almacena el valor maximo
		bmi		.negativo
		mov		r3, r2			@ almacena el nuevo máximo
		mov		r5, r4			@ r5 almacena la posición
	.negativo:
		add 	r4, 1
		subs	r1, 1			@ actualizo indice y flags
		bne		.loopEj7
	mov r0, r5					@ prepara el valor de retorno
	pop		{r4-r5}				@ Repongo los registros no automáticos
	bx		lr					@ retorno al punto de llamada

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@ void asm_invertir(int16_t * vector, uint32_t longitud );
@
@ Parametros recibidos:
@   r0: *vector
@   r1: largo del vector
@
@ Registros usados:
@	r0: recorre en forma ascendente
@ 	r2: memoria auxiliar para swapping
@ 	r3: recorre en forma descendente
@ 	r4: auxiliar  
.thumb_func
	asm_invertir:
	@push	r4				@ Salvo los registros no automaticos (ToDo - falla si descomento)
		mov		r3, r0 			@ seteo r3 al pricipio
		add 	r3, 200			@ llevo al final (TODO sacar numero magico, depende de longitud)
	.loopEj9:
		ldr		r2, [r0]		@ cargo vector[i] en aux e incremento
		ldr		r4, [r3]
		str		r4, [r0]		@ cargo vector[longitud-1 -i] en vector[i]
		str		r2, [r3], -2	@ cargo aux en vector[longitud-1 -i] y decremento
		add		r0, 2
		subs	r1, 2			@ actualizo contador (recorro solo la mitad)
		bne		.loopEj9
	@pop		r4				@ Repongo los registros no automáticos (ToDo - falla si descomento)
	bx		lr					@ retorno al punto de llamada