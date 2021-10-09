#include "c_func.h"


uint32_t c_sum (uint32_t firstOperand, uint32_t secondOperand)
{
    return (firstOperand + secondOperand);
}
void c_zeros(uint32_t *vector, uint32_t longitud)
{
	 uint32_t i;

	    for(i = 0; i < longitud; i++)
	    	vector[i] = 0;
}

void escalar32(uint32_t *vectorIn,uint32_t *vectorOut, uint32_t longitud, uint32_t factor)
{
	uint32_t i = 0 ;
	for(i=0;i<longitud;i++)
	{
		vectorOut[i] = vectorIn[i]*factor;
	} 
}

void escalar16(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud , uint32_t factor)
{
	uint32_t i = 0 ;
	for(i=0;i<longitud;i++)
	{
		vectorOut[i] = vectorIn[i]*factor;
	} 
}

void escalarSat12(uint16_t *vectorIn, uint16_t *vectorOut, uint32_t longitud , uint32_t factor)
{
	uint32_t i = 0 ;
	for(i=0;i<10;i++)
	{
		if(vectorIn[i]*factor >= 4095)
			vectorOut[i] = 4095; 					//saturado
		else 
			vectorOut[i] = vectorIn[i]*factor; 		// no saturado
	} 
}

void C_filtroVentana(uint32_t *vectorIn, uint32_t *vectorOut, uint32_t ventana)
{
	uint32_t i = 0 ;
	
	for(i=0;i<990;i++)
	{
		vectorOut[i] = vectorIn[i]+vectorIn[i+1]+vectorIn[i+2]+vectorIn[i+3]+vectorIn[i+4]+
		vectorIn[i+5]+vectorIn[i+6]+vectorIn[i+7]+vectorIn[i+8]+vectorIn[i+9];
		vectorOut[i] /=10;
	}
		
}