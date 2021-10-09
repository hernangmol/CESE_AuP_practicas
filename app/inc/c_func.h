#pragma once

#include <stdint.h>


uint32_t c_sum (uint32_t firstOperand, uint32_t secondOperand);

void c_zeros(uint32_t *, uint32_t);

void escalar32(uint32_t *,uint32_t *, uint32_t , uint32_t );

void escalar16(uint16_t *,uint16_t *, uint32_t , uint32_t );

void escalarSat12(uint16_t *,uint16_t *, uint32_t , uint32_t );
