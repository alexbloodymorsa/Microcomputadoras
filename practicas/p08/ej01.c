#include <16f877.h>         //Biblioteca para PIC16F877
#fuses HS,NOPROTECT,
#use delay(clock=20000000)  //Configurando el reloj
#org 0x1F00, 0x1FFF void loader16F877(void) {}

void main(){
    while(1){
        output_b(0x01); //Puerto B = 0000 0001
        delay_ms(1000); //Retardo de 1000ms
        output_b(0x00); //Puerto B = 0000 0000
        delay_ms(1000); //Retardo de 1000ms
    } //while
}//main