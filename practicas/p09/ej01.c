#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
/*
Directiva para protocolo I2C, se configura:
-Modo maestro
-SDA en Pin C4
-CSL en Pin C3
-Velocidad baja
*/

int contador=0;   |             //Variable de contador

void escribir_i2c(){      
   i2c_start();                 //Inicializa comunicación
   i2c_write(0x42);             //Localiza el dispositivo
   i2c_write(contador);         //Escribe el contador
   i2c_stop();                  //Termina I2C
    }
    
void main()
{
    while(true)
   {
     escribir_i2c();            //Se escribe el contador
     delay_ms(500);             //Retardo de 500 ms
     contador++;                //Suma uno al contador
   }
}
