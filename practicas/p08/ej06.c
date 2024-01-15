#include <16F877.h>                     //Biblioteca PIC16F877A
#fuses HS,NOWDT,NOPROTECT,NOLVP
#use delay(clock=20000000)              //Configurando el reloj
#org 0x1F00, 0x1FFF void loader16F877(void) {}

/*
var1: variable de entrada
salida: variable para rotar los bits
i: contador
*/
int var1, salida, i;

void main(){
    while(1){
        var1=input_a();                     //Guardar entrada de Puerto A en var1
        switch(var1){                       //Switch con var1
        case 0:                             //Cuando var1 es 0
            output_b(0x00);                 //Puerto B = 0000 0000
            break;
        case 1:                             //Cuando var1 es 1
            output_b(0xFF);                 //Puerto B = 1111 1111
            break;
        case 2:                             //Cuando var1 es 2
            salida = 0x80;                  //salida = 1000 0000
            for(i=0; i<8; i++){             //8 iteraciones
                output_b(salida);           //Puerto B = 1000 0000
                delay_ms(1000);             //Retardo de 1000ms
                salida = salida >> 1;       //Rotar a la derecha
            }
            break;
        case 3:                             //Cuando var1 es 3
            salida = 0x01;                  //salida = 0000 0001
            for(i=0; i<8; i++){             //8 iteraciones
                output_b(salida);           //Puerto B = 0000 0001
                delay_ms(1000);             //Retardo de 1000ms
                salida = salida << 1;       //Rotar a la izquierda
            }
            break;
        case 4:                             //Cuando var1 es 4
            salida = 0x80;                  //salida = 1000 0000
            for(i=0; i<8; i++){             //8 iteraciones
                output_b(salida);           //Puerto B = 1000 0000
                delay_ms(1000);             //Retardo de 1000ms
                salida = salida >> 1;       //Rotar a la derecha
            }
            salida = 0x01;                  //salida = 0000 0001
            for(i=0; i<8; i++){             //8 iteraciones
                output_b(salida);           //Puerto B = 0000 0001
                delay_ms(1000);             //Retardo de 1000ms
                salida = salida << 1;       //Rotar a la izquierda
            }
            break;
        case 5:                             //Cuando var1 es 5
            output_b(0xFF);                 //Puerto B = 1111 1111   
            delay_ms(1000);                 //Retardo de 1000ms
            output_b(0x00);                 //Puerto B = 0000 0000
            delay_ms(1000);                 //Retardo de 1000ms
            break;
        default:                            //Cuando se tiene otro valor
            output_b(0x81);                 //Puerto B = 1000 0001
        }
    }//while
}//main
