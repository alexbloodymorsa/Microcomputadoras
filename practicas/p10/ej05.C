#include <16F877.h>
#device adc=10                                                                //Convertidor a 10 bits
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)
#use i2c(MASTER,SDA=PIN_C4,SCL=PIN_C3,SLOW,NOFORCE_SW)
#include <i2c_LCD.c>
#org 0x1F00,0x1FFF void loader16F877(void){}

int voltaje,bandera,contador,val;
/*
voltaje:    Voltaje del convertidor
bandera:    Modo ascendente o descendente
contador:   Contador de salida
val:        Entrada del puerto B
*/
long contadorT0,contadorD,contadorRB0,contadorS;                              //Contadores interrupciones 
float voltaje_val;                                                            //Voltaje calculado


void escribir_i2c(){                                                          //Escribir en I2C de BCD
   i2c_start();                                                               //Inicia comunicación enviando bit S
   i2c_write(0x42);                                                           //Escribir en dirección 42 (BCD)
   i2c_write(contadorRB0);                                                    //Escribir el contador
   i2c_stop();                                                                //Finaliza comunicación con bit de paro
}

#int_rtcc                                                                     //Interrupción Timer0
clock_isr(){
   contadorT0++;                                                              //Incrementa contador
   
   if(contadorT0 == 15){                                                      //Cada 200ms
      lcd_gotoxy(1,1);
      printf(lcd_putc,"Contador: %x\n",contador);                             //Salida de contador en LCD
      contador++;                                                             //Se incrementa conteo
      if(contador == 255)                                                     //Si el valor es 255
         contador = 0;                                                        //Reinicia contador de salida
      contadorT0 = 0;                                                         //Reinicia contador de interrupción
   }
}

#int_ext                                                                      //Interrupción en R0
detecta_rb0(){
   escribir_i2c();                                                            //Escribe contador en BCD
   contadorRB0++;                                                             //Incrementa contador interrupción
}

#int_rda                                                                      //Interrupción recepción de datos
recepcion_serie(){
   contadorS++;                                                               //Incrementa contador interrupción
   getchar();                                                                 //Se recibe valor de recepción
   printf("Mensaje %lu recibido/n",contadorS);                                //Mensaje recibido en terminal
}

#int_rb                                                                       //Interupción 4 bits más significativos
port_rb(){
   val = input_b();                                                           //Lee la entrada del puerto B
   printf("%x \n",val/0x10);                                                  //Muestra los 4 bits más significativos en hexadecimal
}
    
void main() {
   set_timer0(0);                                                             //Inicia Timer en 00h
   setup_counters(RTCC_INTERNAL,RTCC_DIV_256);                                //Fuente de reloj y pre-divisor
   enable_interrupts(INT_RTCC);                                               //Habilita interrupción de Timer0
   enable_interrupts(GLOBAL);                                                 //Habilita interrupciones globales
   enable_interrupts(INT_EXT);                                                //Habilita interrupción en RB0
   enable_interrupts(INT_RDA);                                                //Habilita interrupción recepción de datos
   enable_interrupts(INT_RB);                                                 //Habilita interrupción 4 bits más significativos B
   ext_int_edge(L_TO_H);                                                      //Configura flanco a detectar
   
   Setup_port_a(ALL_ANALOG);                                                  //Puerto A analógico
   Setup_adc(ADC_CLOCK_INTERNAL);                                             //Define frecuencia de muestreo
   Set_adc_channel(0);                                                        //Se utiliza el canal 0
   
   lcd_init(0x4E, 16, 2);                                                     //Inicializa LCD en dirección 4E

   contadorT0 = 0;
   contador = 0;
   contadorD = 0;
   contadorS = 0;
   contadorRB0 = 0;                                                           //Contadores para interrupciones en 0
   bandera = 0;                                                               //Bandera para cuenta ascendente y descendente
   
   while( TRUE ) {                                                            //Loop infinito
      output_d(contadorD);                                                    //Mostrar contador en Puerto D
      if(bandera == 0)                                                        //Bandera en modo ascendente
         contadorD++;                                                         //Incrementar contador
      else                                                                    //Bandera en modo descendente
         contadorD--;                                                         //Decrementar contador
      if (contadorD == 20)                                                    //Si se llega a 20
         bandera = 1;                                                         //Cambiar a modo descendente
      if (contadorD == 0)                                                     //Si se llega a 0
         bandera = 0;                                                         //Cambiar a modo ascendente
      delay_ms(1000);                                                         //Retardo de 1 segundo
   }
}
