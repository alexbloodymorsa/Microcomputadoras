#include <16F877.h>
#device adc=10                                                       //Convertidor a 10 bits
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)
#use i2c(MASTER,SDA=PIN_C4,SCL=PIN_C3,SLOW,NOFORCE_SW)               //Se utiliza I2C LCD
#include <i2c_LCD.c>
#org 0x1F00,0x1FFF void loader16F877(void){}

int voltaje;                                                         //Valor de voltaje leído
float voltaje_val;                                                   //Voltaje convertido a V

void main() {
   Setup_port_a(ALL_ANALOG);                                         //Puerto A analógico
   Setup_adc(ADC_CLOCK_INTERNAL);                                    //Define frecuencia de muestreo
   Set_adc_channel(0);                                               //Se utiliza el canal 0

   lcd_init(0x4E, 16, 2);                                            //Se inicializa LCD en dirección 4E
   
   while( TRUE ) {
      delay_us(20);                                                  //Retardo de 20us
      voltaje = read_adc();                                          //Se lee voltaje de convertidor
      
      output_d(voltaje);                                             //Muestra voltaje en puerto D
      
      voltaje_val = (voltaje*5.0)/255.0;                             //Conversión a V
      
      lcd_gotoxy(1,1);
      printf(lcd_putc,"Vin = %f V",voltaje_val);                     //Muestra voltaje en V en LCD
      
      printf("Decimal = %u, Hexadecimal = %x \n",voltaje,voltaje);   //Valor decimal y hexadecimal en terminal
      delay_ms(1000);                                                //Retardo de 1 segundo
      }
}
