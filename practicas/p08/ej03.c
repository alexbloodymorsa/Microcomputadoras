#include <16f877.h>         //Biblioteca para PIC16F877
#fuses HS,NOPROTECT,
#use delay(clock=20000000)  //Configurando el reloj
#org 0x1F00, 0x1FFF void loader16F877(void) {}

int var1;               //Variable para guardar la entrada

void main(){
    while(1){
        var1=input_a(); //var1 = Puerto 
        output_b(var1); //Puerto B = var1
    }//while
}//main