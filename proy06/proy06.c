#include <16f877.h>                                            //Biblioteca para PIC16F877
#fuses HS,NOPROTECT,
#device ADC = 8                                                //8 bits de lectura de entrada analógica
#use delay(clock=20000000)                                     //Configurando el reloj
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)                 //Configurando comunicación serie asíncrona
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3, SLOW, NOFORCE_SW)
/*
Directiva para protocolo I2C, se configura:
-Modo maestro
-SDA en Pin C4
-CSL en Pin C3
-Velocidad baja
*/
#include <i2c_LCD.c>                                           //Biblioteca para LCD con I2c
#org 0x1F00,0x1FFF void loader16F877(void){}

int var1,i;
/*
var1: valor leído de entrada analógica
i:    contador en fors
*/
char valor;                                                    //Valor de control
int bandera_rapido,bandera_lento,bandera_luz;
/*
bandera_rapido:   Bandera de activación intermitentes.
bandera_lento:    Bandera de activación direccionales.
bandera_luz:      Bandera de activación luces coche.
*/
int contador_lento,contador_rapido;
/*
contador_rapido:   Contador de tiempo para intermitentes.
contador_lento:    Contador de tiempo para direccionales.
*/


#int_rtcc                                                      //Desbordamiento del TIMER0
clock_isr(){                                                   
   contador_lento++;                                           //Incrementa contador direccionales
   contador_rapido++;                                          //Incrementa contador intermitentes
   
   if(bandera_luz == 1){                                       //Si se activa bandera de luz
      var1 = read_adc();                                       //Se lee el valor del convertidor
      set_pwm1_duty(var1);                                     //El PWM de CCP1 es el valor del convertidor
      delay_ms(15);                                            //Retardo de 15ms
   }
   
   if(contador_lento == 45 && bandera_lento == 1){             //Si se activa la bandera de direccionales y se llega al contador
      lcd_gotoxy(1,1);                          
      printf(lcd_putc,"Direccionales");                        //Indicar en LCD que son direccionales
      for(i  = 0;i < 255; i += 5){                             //De 0 a 255
         set_pwm2_duty(i);                                     //Cambiar el PWM de CCP2 de cinco en cinco
         delay_ms(10);                                         //Cada 10ms
       }
      contador_lento = 0;                                      //Reinicia el contador de direccionales
      lcd_clear();                                             //Se limpia LCD
   }
   
   if(contador_rapido == 10 && bandera_rapido == 1){           //Si se activa la bandera de intermitentes y se cumple el contador
      lcd_gotoxy(1,1);
      printf(lcd_putc,"¡Cuidado!");                            
      lcd_gotoxy(1,2);
      printf(lcd_putc,"Maniobra");                             //Indicar en LCD que se está en una maniobra
      for(i  = 0;i < 255; i += 5){                             //De 0 a 255
         set_pwm2_duty(i);                                     //Cambiar el PWM de CCP2 de cinco en cinco 
         delay_ms(6);                                          //Cada 6ms
      }
      contador_rapido = 0;                                     //Reinicia el contador de intermitentes
      lcd_clear();                                             //Se limpia LCD
   }
}

void main(){
   //Configuración de pwm
   setup_ccp1(CCP_PWM);                                     //Habilita CCP1 como PWM
   setup_ccp2(CCP_PWM);                                     //Habilita CCP2 como PWM
   setup_timer_2(T2_DIV_BY_16, 255, 1);                     //Configura el TIMER2 con predivisor, periodo y postescalador
   
   //Configuración de interrupciones
   set_timer0(0);                                           //Inicia Timer en 0
   setup_counters(RTCC_INTERNAL,RTCC_DIV_256);              //Fuente de reloj y pre-divisor
   enable_interrupts(INT_RTCC);                             //Habilita interrupción de Timer0
   enable_interrupts(GLOBAL);                               //Habilita interrupciones globales
   
   //Configuracion de convertidor A/D
   setup_adc(ADC_CLOCK_INTERNAL);                           //Configura el reloj del convertidor
   setup_adc_ports(AN0);                                    //Se configura AN0 como analógico
   set_adc_channel(0);                                      //Se utiliza el primer canal como el convertidor
   delay_ms(100);                                           //Retardo de 100ms
   
   lcd_init(0x4E, 16, 2);                                   //Inicializa LCD en 4E
   
   //Inicializa todos las banderas y contadores en 0
   bandera_rapido = 0;
   bandera_lento = 0;
   bandera_luz = 0;
   contador_lento = 0;
   contador_rapido = 0;
   contador_luz = 0;
   i = 0;
   
   while(1){
      valor = getchar();                              //Leer valor de comunicación en serie asíncrona
      switch(valor){                                  //Switch con el valor introducido
         case 'L':                                    //L -> Prende los faros del coche
            bandera_luz = 1;                          //Activa la bandera de luz
            break;
         case 'R':                                    //R -> Prende faros de reversa
            output_a(0x02);                           //Salida de faros en A1
            lcd_gotoxy(1,1);
            printf(lcd_putc,"En Reversa");            //Se indica en LCD que se está en reversa
            break;
         case 'l':                                    //l -> Apaga los faros del coche
            bandera_luz = 0;                          //Desactiva la bandera de luz
            set_pwm1_duty(0);                         //El valor de PWM de CCP1 es 0
            break;
         case 'r':                                    //r -> Apaga faros de reversa
            output_a(0x00);                           //Apaga A1
            lcd_gotoxy(1,1);
            printf(lcd_putc,"Avanzando");             //Se indica en LCD que se está avanzando
            break;
         case '0':                                    //0 -> Apagar luces de intermitentes y direccionales
            bandera_rapido = 0;                       //Se apaga bandera intermitentes
            bandera_lento = 0;                        //Se apaga bandera direccionales
            lcd_clear();                              //Se limpia el LCD
            set_pwm2_duty(0);                         //El valor de PWM de CPP2 es 0
            break;
         case '1':                                    //1 -> Solo prender faros una vez
            bandera_rapido = 0;                       //Se apaga bandera de intermitentes
            bandera_lento = 0;                        //Se apaga bandera de direccionales
            for(i  = 0;i < 255; i += 5){              //De 0 a 255
               set_pwm2_duty(i);                      //Cambiar PWM de CCP2 de cinco en cinco
               delay_ms(10);                          //Cada 10ms
            }
            set_pwm2_duty(0);                         //El valor de PWM de CCP2 es 0
            break;
         case '2':                                    //2 -> Prender direccionales
            bandera_rapido = 0;                       //Se apaga bandera intermitentes
            bandera_lento = 1;                        //Se prende bandera direccionales
            contador_lento = 0;                       //Reinicia el contador direccionales
            contador_rapido = 0;                      //Reinicia el contador intermitentes
            break;
         case '3':                                    //3 -> Prender intermitentes
            bandera_rapido = 1;                       //Se prende bandera intermitentes
            bandera_lento = 0;                        //Se apaga bandera direccionales
            contador_lento = 0;                       //Reinicia el contador direccionales
            contador_rapido = 0;                      //Reinicia el contador intermitentes
            break;
         default:
            printf("\nVALOR NO VÁLIDO\n");            //Imprimir valor no válido
      };
   }
}
