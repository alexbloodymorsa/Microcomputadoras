#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)

int contador;

#int_EXT                         //Interrupción en RB0
ext_int(){
   contador++;                   //Se incrementa el contador
   output_d(contador);           //Salida del contador en puerto D
}
void main() {
   ext_int_edge(L_TO_H);         //Configura flanco a detectar
   enable_interrupts(INT_EXT);   //Habilitando interrupción en RB0
   enable_interrupts(GLOBAL);    //Habilitando interrupciones globales
   output_d(0x00);               //Salida de 0 en el puerto D
   while( TRUE ) {}              //Loop infinito
}
