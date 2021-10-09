#pragma once

#include <stdint.h>

extern uint32_t asm_zeros (uint32_t *vector, uint32_t longitud);

extern uint32_t asm_sum (uint32_t firstOperand, uint32_t secondOperand);

extern void asm_escalar32 (uint32_t * , uint32_t * , uint32_t , uint32_t );

extern void asm_escalar16 (uint16_t * , uint16_t * , uint32_t , uint32_t );

extern void asm_svc (void);
