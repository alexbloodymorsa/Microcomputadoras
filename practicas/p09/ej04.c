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

int contador=0;                                          //Variable de contador

void escribir_i2c(){
   i2c_start();                                          //Inicia comunicación
   i2c_write(0x42);                                      //Dirección dispositivo escritura
   i2c_write(contador);                                  //Escribir el contador
   i2c_stop();                                           //Finalizar escritura
    }

void leer_i2c(){
   i2c_start();                                          //Inicia comunicación
   i2c_write(0x45);                                      //Dirección dispositivo lectura
   contador = i2c_read(0);                               //Lectura del contador
   i2c_stop();                                           //Finalizar lectura
    }
    
void main()
{
   lcd_init(0x4E, 16, 2);                                //Inicializar el LCD en dirección 4E
    while(true)
   {
     leer_i2c();                                         //Lectura de contador
     output_d(contador);                                 //Puerto D = contador
     escribir_i2c();                                     //Escritura de contador
     lcd_gotoxy(1,1);                                    //Posicionarse en columna 1, renglón 1
     printf(lcd_putc, "UNAM");                           //Escritura de UNAM
     lcd_gotoxy(1,2);                                    //Posicionarse en columna 1, renglón 2
     printf(lcd_putc, "Contador=%X", contador);          //Escritura de "Contador = HEX"
     delay_ms(500);                                      //Retardo de 500ms
   }
}
