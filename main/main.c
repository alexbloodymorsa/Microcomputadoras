#include <16f877.h>                                            //Biblioteca para PIC16F877
#fuses HS,NOWDT,NOPROTECT,
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

int contador, avanza, i;
/*
contador:   contador para los metros del vehículo
avanza:     bandera para contar el avance en metros
*/
unsigned int intensidad;                                       //Intensidad del LED a partir del convertidor
int bandera_derecha, bandera_izquierda, bandera_luz, bandera_maniobra;
/*
BANDERAS
derecha:    bandera para activar direccional derecha
izquierda:  bandera para activar direccional izquierda
luz:        bandera para activar faros de luz
maniobra:   bandera para activar intermitentes
*/
int contador_izquierda,contador_derecha;
/*
CONTADORES
izquierda:  contador para direccional izquierda
derecha:    contador para direccional derecha
*/
float metros;                                                  //número de metros recorridos
char valor;                                                    //valor de control del coche

#int_rtcc                                                      //Interrupción desbordamiento TIMER0
clock_isr(){
   contador_izquierda++;                                       //Incrementa contador izquierda
   contador_derecha++;                                         //Incrementa contador derecha
   
   //En caso de que se active bandera de avanzar
   if(avanza == 1){
      contador++;                                              //Incrementa contador de metros
      lcd_gotoxy(1,2);                                         //Posicionar cursor en segundo renglón
      printf(lcd_putc,"Metros: %f m", metros);                 //Muestra metros en LCD
   }
   
   //En caso de que se cumpla el segundo
   if(contador == 76){
      metros += 0.1325;                                        //Aumentar metros por 0.1325
      contador = 0;                                            //Reinicia contador
   }
   
   //En caso de que se prendan las luces y se apaguen direccionales
   if(bandera_luz == 1 && bandera_izquierda == 0 && bandera_derecha == 0){
      intensidad = read_adc();                                 //La intensidad es el valor del convertidor
      set_pwm1_duty(180-intensidad);                           //PWM1 es el inverso del convertidor
      set_pwm2_duty(180-intensidad);                           //PWM2 es el inverso del convertidor
      delay_ms(10);                                            //Retardo de 10ms
   }
   
   //En caso de activar la direccional izquierda
   if((contador_izquierda == 45 && bandera_izquierda == 1) || bandera_maniobra == 1 ){
      for(i  = 0;i < 255; i += 5){                             //De 0 a 255
         set_pwm1_duty(i);                                     //Incrementar PWM1 de 5 en 5
         delay_ms(10);                                         //Retardo de 10ms
       }
      contador_izquierda = 0;                                  //Reiniciar contador direccional izquierda
   }
   
   //En caso de activar la direccional derecha
   if((contador_derecha == 45 && bandera_derecha == 1) || bandera_maniobra == 1){
      for(i  = 0;i < 255; i += 5){                             //De 0 a 255
         set_pwm2_duty(i);                                     //Incrementar PWM2 de 5 en 5
         delay_ms(10);                                         //Retardo de 10ms
      }
      contador_derecha = 0;                                    //Reiniciar contador direccional derecha
   }
}

void main(){
   //configuracion de pwm
   setup_ccp1(CCP_PWM);                                     //Habilita CCP1 como PWM
   setup_ccp2(CCP_PWM);                                     //Habilita CCP2 como PWM
   setup_timer_2(T2_DIV_BY_16, 255, 1);                     //Configura el TIMER2 con predivisor, periodo y postescalador
   
   //configuracion de interrupciones
   set_timer0(0);                                           //Inicia Timer en 0
   setup_counters(RTCC_INTERNAL,RTCC_DIV_256);              //Fuente de reloj y pre-divisor
   enable_interrupts(INT_RTCC);                             //Habilita interrupción de Timer0
   enable_interrupts(GLOBAL);                               //Habilita interrupciones globales
   
   //configuracion de convertidor a/d
   setup_adc(ADC_CLOCK_INTERNAL);                           //Configura el reloj del convertidor
   setup_adc_ports(32);                                     //Configura el puerto E0 como analógico
   set_adc_channel(5);                                      //Se configura el canal como el puerto E0
   delay_ms(100);                                           //Retardo de 100ms
   
   lcd_init(0x4E, 16, 2);                                   //Inicializa LCD en 0x4E
   
   //Se inicializan todas las variables en 0
   contador = 0;
   avanza = 0;
   metros = 0;
   bandera_derecha = 0;
   bandera_izquierda = 0;
   bandera_luz = 0;
   contador_izquierda = 0;
   contador_derecha = 0;
   i = 0;
   
   while(TRUE){
      valor = getc();                              //Leer valor de comunicación en serie asíncrona
      switch(valor){                               //Switch con el valor introducido
         case 'S':                                 //S -> Valor para parar el coche
            set_pwm1_duty(0);                      //Cambiar valor PWM1 a 0
            set_pwm2_duty(0);                      //Cambiar valor PWM2 a 0
            lcd_clear();                           //Limpiar el LCD
            lcd_gotoxy(1,1);                       //Posicionar cursor en primer renglón
            printf(lcd_putc,"EN PARO");            //Indicar en LCD que está en paro el coche
            avanza = 0;                            //Desactivar bandera de avance
            output_b(0x00);                        //Apagar motores
            output_a(0x00);                        //Apagar luces reversa
            bandera_derecha = 0;                   //Apagar direccional derecha
            bandera_izquierda = 0;                 //Apagar direccional izquierda
            break;
         case 'A':                                 //A -> Valor para que el coche avance
            set_pwm1_duty(0);                      //Cambiar valor PWM1 a 0
            set_pwm2_duty(0);                      //Cambiar valor PWM2 a 0
            lcd_clear();                           //Limpiar el LCD
            lcd_gotoxy(1,1);                       //Posicionar cursor en primer renglón
            printf(lcd_putc,"AVANZANDO");          //Indicar en LCD que el coche está avanzando
            avanza = 1;                            //Activar bandera de avance
            output_b(0x0A);                        //Motores en avance
            output_a(0x00);                        //Apagar luces reversa
            bandera_derecha = 0;                   //Apagar direccional derecha
            bandera_izquierda = 0;                 //Apagar direccional izquierda
            break;
         case 'T':                                 //T -> Valor para que el coche retroceda
            set_pwm1_duty(0);                      //Cambiar valor PWM1 a 0
            set_pwm2_duty(0);                      //Cambiar valor PWM2 a 0
            lcd_clear();                           //Limpiar el LCD
            lcd_gotoxy(1,1);                       //Posicionar cursor en primer renglón
            printf(lcd_putc,"EN REVERSA");         //Indicar en LCD que el coche está en reversa
            avanza = 1;                            //Activar bandera de avance
            output_b(0x05);                        //Motores en reversa
            output_a(0x06);                        //Prender luces reversa
            bandera_derecha = 0;                   //Apagar direccional derecha
            bandera_izquierda = 0;                 //Apagar direccional izquierda
            break;
         case 'D':                                 //D -> Valor para girar a la derecha
            set_pwm1_duty(0);                      //Cambiar valor PWM1 a 0
            lcd_clear();                           //Limpiar el LCD
            lcd_gotoxy(1,1);                       //Posicionar cursor en primer renglón
            printf(lcd_putc,"DERECHA");            //Indicar en LCD que el coche gira a la derecha
            avanza = 0;                            //Desactivar bandera de avance   
            output_b(0x09);                        //Motores giran a la derecha
            output_a(0x02);                        //Prender luz de reversa derecha
            bandera_derecha = 1;                   //Prender direccional derecha
            bandera_izquierda = 0;                 //Apagar direccional izquierda
            contador_derecha = 0;                  //Reinicia contador derecha
            contador_izquierda = 0;                //Reinicia contador izquierda
            break;
         case 'I':                                 //I -> Valor para girar a la izquierda
            set_pwm2_duty(0);                      //Cambiar valor PWM2 a 0
            bandera_maniobra = 0;                  //Apagar bandera maniobra
            lcd_clear();                           //Limpiar el LCD
            lcd_gotoxy(1,1);                       //Posicionar cursor en primer renglón
            printf(lcd_putc,"IZQUIERDA");          //Indicar en LCD que el coche gira a la izquierda
            avanza = 0;                            //Desactivar bandera de avance
            output_b(0x06);                        //Motores giran a la izquierda
            output_a(0x04);                        //Prender luz de reversa izquierda
            bandera_derecha = 0;                   //Apagar direccional derecha
            bandera_izquierda = 1;                 //Prender direccional izquierda
            contador_derecha = 0;                  //Reinicia contador derecha
            contador_izquierda = 0;                //Reinicia contador izquierda
            break;
         case 'M':                                 //M -> Valor para activar maniobra
            bandera_maniobra = 1;                  //Prender bandera maniobra
            lcd_clear();                           //Limpiar el LCD
            lcd_gotoxy(1,1);                       //Posicionar cursor en primer renglón
            printf(lcd_putc,"MANIOBRA");           //Indicar en LCD que el coche está en maniobra
            break;
         case 'm':                                 //m -> Valor para apagar Maniobra
            bandera_maniobra = 0;                  //Apagar la bandera de maniobra
            lcd_clear();                           //Limpiar el LCD
            set_pwm1_duty(0);                      //Cambiar valor PWM1 a 0
            set_pwm2_duty(0);                      //Cambiar valor PWM2 a 0
            break;
         case 'L':                                 //L -> Valor para prender las luces
            bandera_maniobra = 0;                  //Apagar la bandera de maniobra
            bandera_luz = 1;                       //Prender la bandera de faros
            break;
         case 'l':                                 //l -> Valor para apagar luces
            bandera_luz = 0;                       //Apagar la bandera de faros
            set_pwm1_duty(0);                      //Cambiar valor PWM1 a 0
            set_pwm2_duty(0);                      //Cambiar valor PWM2 a 0
            break;
         default:
            
      };
   }
}
