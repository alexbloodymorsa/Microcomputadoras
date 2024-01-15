#include <16F877.h>                                                           //Biblioteca PIC16F877A
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)                                                    //Configurando el reloj
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)                                //Configuración puerto en serie
#use i2c(MASTER,SDA=PIN_C4,SCL=PIN_C3,SLOW,NOFORCE_SW)
/*
Directiva para protocolo I2C, se configura:
-Modo maestro
-SDA en Pin C4
-CSL en Pin C3
-Velocidad baja
*/
#include <i2c_LCD.c>                                                          //Biblioteca LCD para I2C
#org 0x1F00,0x1FFF void loader16F877(void){}

int contador,avanza;
/*
contador:   Contador de Timer0
avanza:     Bandera de si avanza o no
*/
float metros;                                                                 //Metros recorridos
char valor;                                                                   //Valor de control

#int_rtcc
clock_isr(){
   if(avanza == 1)                                                            //Si avanza se incrementa el contador
      contador++;                                                             //Incrementa el contador
   
   if(contador == 76){                                                        //Cada segundo
      metros += 0.1325;                                                       //Se aumentan los metros en .13
      lcd_gotoxy(1,1);  
      printf(lcd_putc,"Metraje: \n");                                         
      lcd_gotoxy(1,2);
      printf(lcd_putc,"%f m\n",metros);                                       //Imprimir en LCD: "Metraje: metros"
      contador = 0;                                                           //Se reinicia el contador
   }
}

void main() {
   set_timer0(0);                                                             //Inicia Timer en 00h
   setup_counters(RTCC_INTERNAL,RTCC_DIV_256);                                //Fuente de reloj y pre-divisor
   enable_interrupts(INT_RTCC);                                               //Habilita interrupción de Timer0
   enable_interrupts(GLOBAL);                                                 //Habilita interrupciones globales
   
   lcd_init(0x4E, 16, 2);                                                     //Incializa LCD en 4E

   contador = 0;                                                              //Inicializa contador interrupción en 0
   avanza = 0;                                                                //Bandera por si avanza
   metros = 0;                                                                //Variable de metros recorridos
   
   while( TRUE ) {
      valor = getc();                                                         //Recepción de un caracter
      if(valor == 'S'){                                                       //Si es S
         avanza = 0;                                                          //Bandera en no avanza
         output_b(0x00);                                                      //Se para el coche
      }
      if(valor == 'A'){                                                       //Si es A
         avanza = 1;                                                          //Bandera en avanza
         output_b(0x0A);                                                      //Avanza el coche
      }
      if(valor == 'T'){                                                       //Si es T
         avanza = 1;                                                          //Bandera en avanza
         output_b(0x05);                                                      //Retrocede el coche
      }
      if(valor == 'D'){                                                       //Si es D
         avanza = 0;                                                          //Bandera en no avanza
         output_b(0x09);                                                      //Gira a la derecha
      }
      if(valor == 'I'){                                                       //Si es I
         avanza = 0;                                                          //Bandera en no avanza
         output_b(0x06);                                                      //Gira a la izquierda
      }
      printf("%c", valor);                                                    //Imprime valor leído en terminal
   }
}
