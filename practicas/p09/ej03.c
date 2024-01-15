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
#include <i2c_LCD.c> //Utilizado para el protocolo entre LCD e I2C

int contador=0;                                       //Variable de contador                  

void escribir_i2c(){
   i2c_start();                                       //Inicia comunicación
   i2c_write(0x42);                                   //Localiza el dispositivo
   i2c_write(contador);                               //Escribe el contador
   i2c_stop();                                        //Termina I2C
    }
    
void main()
{
   lcd_init(0x4E, 16, 2);                             //Inicialización LCD con dirección
    while(true)
   {
     lcd_gotoxy(1,1);                                 //Colocarse en renglón 1, columna 1
     printf(lcd_putc, "UNAM");                        //Imprimir "UNAM"
     lcd_gotoxy(1,2);                                 //Colocarse en renglón 2, columna 1
     printf(lcd_putc, "Contador=%d", contador);       //Imprimir "Contador = numero"
     escribir_i2c();                                  //Se escribe el contador
     output_d(contador);                              //Puerto D = contador
     delay_ms(500);                                   //Retardo de 500ms
     contador++;                                      //Suma uno al contador
   }
}
