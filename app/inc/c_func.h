#pragma once

#include <stdint.h>


uint32_t c_sum (uint32_t firstOperand, uint32_t secondOperand);

void c_zeros(uint32_t *, uint32_t);

void escalar32(uint32_t *,uint32_t *, uint32_t , uint32_t );

void escalar16(uint16_t *,uint16_t *, uint32_t , uint32_t );

void escalarSat12(uint16_t *,uint16_t *, uint32_t , uint32_t );

void C_filtroVentana(uint32_t *,uint32_t *, uint32_t );

void C_pack16(int32_t *, int16_t *, uint32_t );

uint32_t C_posMax(int32_t * , uint32_t );

void C_invertir(int16_t * , uint32_t );
