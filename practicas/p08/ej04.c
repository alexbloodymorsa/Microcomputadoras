#include <16f877.h>                                 //Biblioteca de PIC16F877A
#fuses HS,NOPROTECT,
#use delay(clock=20000000)                          //Configurando el reloj
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)      //Configurando Baud y recepción
#org 0x1F00, 0x1FFF void loader16F877(void) {}

void main(){
    while(1){
        output_b(0xff);                             //Puerto B = 1111 1111
        printf(" Todos los bits encendidos \n\r");  //Impresión en terminal
        delay_ms(1000);                             //Retardo de 1000ms
        output_b(0x00);                             //Puerto B = 0000 0000
        printf(" Todos los leds apagados \n\r");    //Impresión en terminal
        delay_ms(1000);                             //Retardo de 1000ms
    }//while
}//main