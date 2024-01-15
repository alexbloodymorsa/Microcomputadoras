#include <16F877.h>
#device adc=10                                                          //Convertidor a 10 bits
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)
#use i2c(MASTER,SDA=PIN_C4,SCL=PIN_C3,SLOW,NOFORCE_SW)
#include <i2c_LCD.c>
#org 0x1F00,0x1FFF void loader16F877(void){}

int voltaje;                                                            //Valor de voltaje del convertidor
long contador;                                                          //Valor de contador para la interrupción 
float voltaje_val;                                                      //Valor calculado de V

#int_rtcc                                                               //Interrupción por Timer0
clock_isr(){
   contador++;                                                          //Incrementar el contador
   
   if(contador == 763){                                                 //Realizar cada segundo
      voltaje = read_adc();                                             //Se lee voltaje de convertidor
      
      output_d(voltaje);                                                //Muestra voltaje en puerto D
      
      voltaje_val = (voltaje*5.0)/255.0;                                //Conversión a V
      
      lcd_gotoxy(1,1);
      printf(lcd_putc,"Vin = %f V",voltaje_val);                        //Muestra voltaje en V en LCD
      
      printf("Decimal = %u, Hexadecimal = %x \n",voltaje,voltaje);      //Valor decimal y hexadecimal en terminal
      
      contador = 0;
   }
}

void main() {
   set_timer0(0);                                                       //Inicia Timer en 00h
   setup_counters(RTCC_INTERNAL,RTCC_DIV_256);                          //Fuente de reloj y pre-divisor
   enable_interrupts(INT_RTCC);                                         //Habilita interrupción de Timer0
   enable_interrupts(GLOBAL);                                           //Habilita interrupciones globales
   
   Setup_port_a(ALL_ANALOG);                                            //Puerto A analógico
   Setup_adc(ADC_CLOCK_INTERNAL);                                       //Define frecuencia de muestreo
   Set_adc_channel(0);                                                  //Se utiliza el canal 0
   
   lcd_init(0x4E, 16, 2);                                               //Se inicializa LCD en dirección 4E
   contador = 0;                                                        //Inicializa contador en 0
   
   while( TRUE ) {}                                                     //Loop infinito
}
