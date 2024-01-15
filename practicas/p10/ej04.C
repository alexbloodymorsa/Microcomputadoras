#include <16F877.h>
#device adc=10                                                                //Convertidor a 10 bits
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)
#use i2c(MASTER,SDA=PIN_C4,SCL=PIN_C3,SLOW,NOFORCE_SW)
#org 0x1F00,0x1FFF void loader16F877(void){}
#include <i2c_LCD.c>

int voltaje;                                                                  //Voltaje del convertidor
long contador1,contador2,contador3;                                           //Tres contadores
float voltaje_val;                                                            //Valor calculado de voltaje
long val3;                                                                    //Valor del conteo

#int_rtcc                                                                     //Interrupción por Timer0
clock_isr(){
   contador1++;                                                               
   contador2++;
   contador3++;                                                               //Se incrementa el valor de todos los contadores
   
   if(contador1 == 763){                                                      //Cada diez segundos
      voltaje = read_adc();                                                   //Se lee el valor del convertidor
      
      voltaje_val = (voltaje*5.0)/255.0;                                      //Se calcula el valor en V
      
      lcd_gotoxy(1,1);
      printf(lcd_putc,"Vin = %f V",voltaje_val);                              //Se muestra en LCD el voltaje calculado
      
      contador1 = 0;                                                          //Se reinicia el contador
   }
   
   if(contador2 == 1907){                                                     //Cada 25 segundos
      printf("\nAlejandro Barreiro Valdez\tNum. cuenta: 317520888\n");        
      printf("Jessica Zepeda Baeza\tNum. cuenta: 317520747\n");
      printf("Grupo Teor�a 1\n");
      printf("Grupo Laboratorio 4\n");                                        //Valores a imprimir en la terminal
      
      contador2 = 0;                                                          //Se reinicia el contador
   }
   
   if(contador3 == 19){                                                       //Cada 250 ms
      output_d(val3);                                                         //Se muestra el conteo
      val3++;                                                                 //Se incrementa el conteo
      contador3 = 0;                                                          //Se reinicia el contador
   }
   
}

void main() {
   set_timer0(0);                                                             //Inicia Timer en 00h
   setup_counters(RTCC_INTERNAL,RTCC_DIV_256);                                //Fuente de reloj y pre-divisor
   enable_interrupts(INT_RTCC);                                               //Habilita interrupción de Timer0
   enable_interrupts(GLOBAL);                                                 //Habilita interrupciones globales
   
   Setup_port_a(ALL_ANALOG);                                                  //Puerto A analógico
   Setup_adc(ADC_CLOCK_INTERNAL);                                             //Define frecuencia de muestreo
   Set_adc_channel(0);                                                        //Se utiliza el canal 0
   
   lcd_init(0x4E, 16, 2);                                                     //Inicializa LCD en dirección 4E
   contador1 = 0;
   contador2 = 0;                                                             
   contador3 = 0;                                                             //Se inicializan los contadores
   val3 = 0;                                                                  //Inicializa el conteo
 
   while( TRUE ) {                                                            //Loop infinito
   }
}
