#include "board.h"
#include "c_func.h"
#include "asm_func.h"

#include <stdlib.h>
#include <stdnoreturn.h>

// definir el ejercicio con el que se va a trabajar

#define EJERCICIO_9

// Variable que se incrementa cada vez que se llama al handler de interrupcion
// del SYSTICK.
static volatile uint32_t s_ticks = 0;

// Contador de ciclos del sistema
static volatile uint32_t * H_DWT_CYCCNT	 = (uint32_t *)0xE0001004;
    


// Inicia soporte de la placa y periodo de la interrupcion del SYSTICK
// cada 1 milisegundo.
static void Inicio (void)
{
    Board_Init ();
    SystemCoreClockUpdate ();
    SysTick_Config (SystemCoreClock / 1000);
    //Inicializo la cuenta de ciclos
    static uint32_t * H_DWT_DEMCR	 = (uint32_t *)0xE000EDFC; 
    static uint32_t * H_DWT_CTRL	 = (uint32_t *)0xE0001000;
    // bit24[TRCENA]   = habilita todos los DWT
	*H_DWT_DEMCR |= 1<<24;
	// bit0[CYCCNTENA] =  enable CYCCNT
	*H_DWT_CTRL |= 1;
}


// Segun la configuracion realizada en Inicio(), este handler de interrupcion
// se ejecutara cada 1 milisegundo.
void SysTick_Handler (void)
{
    ++ s_ticks;
}


static void Suma (void)
{
    volatile uint32_t cyclesC, cyclesAsm;
	
	// carga los uS a esperar
	//t *= (SystemCoreClock/1000000);
	// chequea si el contador alcanzó la cuenta
	//while(*H_DWT_CYCCNT < t);
    
    const uint32_t A = 20;
    const uint32_t B = 30;

    *H_DWT_CYCCNT = 0;
    const uint32_t SumResult_C = c_sum (A, B);
    cyclesC = *H_DWT_CYCCNT;
    *H_DWT_CYCCNT = 0;
    const uint32_t SumResult_Asm = asm_sum (A, B);
    cyclesAsm = *H_DWT_CYCCNT;

    // Actividad de debug: SumResult_C y SumResult_Asm deberian contener el
    // mismo valor.
    __BKPT (0);

    (void) SumResult_C;
    (void) SumResult_Asm;
}

static void zeros (void)
{
    volatile uint32_t cyclesC, cyclesAsm;
     
    uint32_t vector[8] = { (uint32_t)-1, (uint32_t)-2, (uint32_t)-3,
						   (uint32_t)-4, (uint32_t)-5, (uint32_t)-6,
						   (uint32_t)-7, (uint32_t)-8 };

    __BKPT (0);

    *H_DWT_CYCCNT = 0;
    c_zeros(vector, 8);
    cyclesC = *H_DWT_CYCCNT;

    *H_DWT_CYCCNT = 0;
    asm_zeros (vector, 8);
    cyclesAsm = *H_DWT_CYCCNT;
    
}

static void productoEscalar32 (void)
{
	volatile uint32_t cyclesC, cyclesAsm;
    
    static uint32_t Entrada[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	static uint32_t Resultado[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static uint32_t cantidad = sizeof(Entrada) / sizeof(uint32_t);
    static uint32_t factor = 2;

	
    *H_DWT_CYCCNT = 0;
    escalar32(Entrada, Resultado, cantidad, factor);
    cyclesC = *H_DWT_CYCCNT;

    *H_DWT_CYCCNT = 0;
    asm_escalar32(Entrada, Resultado, cantidad, factor);
    cyclesAsm = *H_DWT_CYCCNT;

}

static void productoEscalar16 (void)
{
	volatile uint32_t cyclesC, cyclesAsm;
    
    static uint16_t Entrada[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	static uint16_t Resultado[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static uint32_t cantidad = sizeof(Entrada) / sizeof(uint16_t);
    static uint32_t factor = 2;

	
    *H_DWT_CYCCNT = 0;
    escalar16(Entrada, Resultado, cantidad, factor);
    cyclesC = *H_DWT_CYCCNT;

    *H_DWT_CYCCNT = 0;
    asm_escalar16(Entrada, Resultado, cantidad, factor);
    cyclesAsm = *H_DWT_CYCCNT;

}

static void productoEscalarSat12 (void)
{
	volatile uint32_t cyclesC, cyclesAsm;
    
    static uint16_t Entrada[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	static uint16_t Resultado[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	static uint32_t cantidad = sizeof(Entrada) / sizeof(uint16_t);
    static uint32_t factor = 500;   //pongo un factor que haga saturar

	
    *H_DWT_CYCCNT = 0;
    escalarSat12(Entrada, Resultado, cantidad, factor);
    cyclesC = *H_DWT_CYCCNT;

    *H_DWT_CYCCNT = 0;
    asm_escalarSat12(Entrada, Resultado, cantidad, factor);
    cyclesAsm = *H_DWT_CYCCNT;

}

static void filtroVentana (void)
{
	volatile uint32_t cyclesC, cyclesAsm;
    uint32_t i = 0;
    uint32_t j = 0;

    static uint32_t Entrada[1000];
	static uint32_t Salida[1000];
    static uint32_t ventana = 10;
	
    // cargo el vector de entrada con una señal diente de sierra
    for (i=0;i<1000;i++)
    {
        Entrada[i]=j;
        if(j++ == 20)
            j = 0;
    }
    
    __BKPT (0);
	*H_DWT_CYCCNT = 0;
    C_filtroVentana(Entrada, Salida, ventana);
    __BKPT (0);
    cyclesC = *H_DWT_CYCCNT;

    for (i=0;i<1000;i++)
    {
        Salida[i]=0;
    }

    __BKPT (0);
    *H_DWT_CYCCNT = 0;
    asm_filtroVentana(Entrada, Salida, ventana);
    __BKPT (0);
    cyclesAsm = *H_DWT_CYCCNT;

}

static void empaquetar16 (void)
{
	volatile uint32_t cyclesC, cyclesAsm;
    uint32_t i;
    
    static int32_t Entrada[100];
    static int16_t Salida[100];
	static uint32_t cantidad = sizeof(Entrada) / sizeof(int32_t);

    for (i=0;i<cantidad;i++)
            Entrada[i]=i*10000000;
       	
    __BKPT (0);
    *H_DWT_CYCCNT = 0;
    C_pack16(Entrada, Salida, cantidad);
     __BKPT (0);
    cyclesC = *H_DWT_CYCCNT;

    for (i=0;i<cantidad;i++)
            Salida[i]=0;

    __BKPT (0);
    *H_DWT_CYCCNT = 0;
    asm_pack16(Entrada, Salida, cantidad);
     __BKPT (0);
    cyclesAsm = *H_DWT_CYCCNT;

}


static void posicionMaximo (void)
{
	volatile uint32_t cyclesC, cyclesAsm;
    uint32_t i,j = 0;
    
    static uint32_t Entrada[100];
	static uint32_t cantidad = sizeof(Entrada) / sizeof(int32_t);

    for (i=0;i<cantidad;i++)
    {
        Entrada[i]=j;
        if(j++ == 20)
            j = 0;
    }
   	
    __BKPT (0);
    *H_DWT_CYCCNT = 0;
    C_posMax(Entrada, cantidad);
     __BKPT (0);
    cyclesC = *H_DWT_CYCCNT;

    *H_DWT_CYCCNT = 0;
    asm_posMax(Entrada, cantidad);
     __BKPT (0);
    cyclesAsm = *H_DWT_CYCCNT;

}

static void invertir (void)
{
	volatile uint32_t cyclesC, cyclesAsm;
    uint32_t i;
    
    static int16_t vector[100];
    static uint32_t cantidad = sizeof(vector) / sizeof(int16_t);

    for (i=0;i<cantidad;i++)
        vector[i]=i;
                   	
    __BKPT (0);
    *H_DWT_CYCCNT = 0;
    C_invertir(vector, cantidad);
     __BKPT (0);
    cyclesC = *H_DWT_CYCCNT;

    for (i=0;i<cantidad;i++)
        vector[i]=i;

    __BKPT (0);
    *H_DWT_CYCCNT = 0;
    asm_invertir(vector, cantidad);
     __BKPT (0);
    cyclesAsm = *H_DWT_CYCCNT;

}



static void LlamandoAMalloc (void)
{
    // De donde saca memoria malloc?
    // (se vera en clase)
    void * ptr = malloc (2048);

    (void) ptr;
}


static void PrivilegiosSVC (void)
{
    // Obtiene valor del registro de 32 bits del procesador llamado "control".
    // El registro guarda los siguientes estados:
    // bit 2: Uso de FPU en el contexto actual. Usado=1, no usado=0.
    // bit 1: Mapeo del stack pointer(sp). MSP=0, PSP=1.
    // bit 0: Modo de ejecucion en Thread. Privilegiado=0, No privilegiado=1.
    //        Recordar que este valor solo se usa en modo Thread. Las
    //        interrupciones siempre se ejecutan en modo Handler con total
    //        privilegio.
    uint32_t x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    x |= 1;
    // bit 0 a modo No privilegiado.
    __set_CONTROL (x);

    // En este punto se estaria ejecutando en modo No privilegiado.
    // Lectura del registro "control" para confirmar.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    x &= ~1u;
    // Se intenta volver a modo Privilegiado (bit 0, valor 0).
    __set_CONTROL (x);

    // Confirma que esta operacion es ignorada por estar ejecutandose en modo
    // Thread no privilegiado.
    x = __get_CONTROL ();

    // Actividad de debug: Ver registro "control" y valor de variable "x".
    __BKPT (0);

    // En este punto, ejecutando en modo Thread no privilegiado, la unica forma
    // de volver a modo privilegiado o de realizar cualquier cambio que requiera
    // modo privilegiado, es pidiendo ese servicio a un hipotetico sistema
    // opertivo de tiempo real.
    // Para esto se invoca por software a la interrupcion SVC (Supervisor Call)
    // utilizando la instruccion "svc".
    // No hay intrinsics para realizar esta tarea. Para utilizar la instruccion
    // es necesario implementar una funcion en assembler. Ver el archivo suma.S.
    asm_svc ();

    // El sistema operativo (el handler de SVC) deberia haber devuelto el modo
    // de ejecucion de Thread a privilegiado (bit 0 en valor 0).
    x = __get_CONTROL ();

    // Fin del ejemplo de SVC
}


// Handler de la interrupcion "SVC" (Supervisor Call).
// Usado por el ejemplo "EjemploPrivilegiosSVC".
void SVC_Handler (void)
{
    // Se obtiene el valor del registro "control". El bit 0 indica el nivel
    // de privilegio en modo "Thread". Deberia ser 1: No privilegiado.
    uint32_t x = __get_CONTROL ();

    // Borra el bit 0. Nuevo valor 0: privilegiado.
    x &= ~1u;

    // Asigna el nuevo valor al registro "control". Esta operacion deberia
    // ejecutarse ya que todo manejador de interrupciones se ejecuta en modo
    // "Handler" con total privilegio.
    __set_CONTROL (x);
}


noreturn void LoopInfinito (void)
{
    while (1)
    {
        // Procesador en modo espera hasta que ocurra una interrupcion
        // (Bajo consumo)
        __WFI();
    }
}


int main (void)
{
    Inicio ();

#ifdef EJERCICIO_0
    Suma ();

    PrivilegiosSVC ();

    LlamandoAMalloc ();
#endif

#ifdef EJERCICIO_1

    zeros();

#endif

#ifdef EJERCICIO_2

    productoEscalar32 ();

#endif

#ifdef EJERCICIO_3

    productoEscalar16 ();

#endif

#ifdef EJERCICIO_4

    productoEscalarSat12 ();

#endif

#ifdef EJERCICIO_5

    filtroVentana ();

#endif

#ifdef EJERCICIO_6

    empaquetar16();

#endif

#ifdef EJERCICIO_7

    posicionMaximo();

#endif

#ifdef EJERCICIO_9

    invertir();

#endif
   
    LoopInfinito ();
}
