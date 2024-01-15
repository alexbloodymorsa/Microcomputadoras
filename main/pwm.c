#include <16f877.h>         //Biblioteca para PIC16F877
#fuses HS,NOPROTECT,
#device ADC = 8
#use delay(clock=20000000)  //Configurando el reloj

int var1;

void main(){
   setup_adc(ADC_CLOCK_DIV_32);
   setup_adc_ports(AN0);
   set_adc_channel(0);
   setup_ccp1(CCP_PWM);
   setup_timer_2();
   delay_ms(100);
   while(1){
      var1 = read_adc();
      set_pwm1_duty(var1);
      delay_ms(15);
   }
}
