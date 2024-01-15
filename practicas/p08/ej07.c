#include <16F877.h>                     //Biblioteca PIC16F877A
#fuses HS,NOWDT,NOPROTECT,NOLVP
#use delay(clock=20000000)              //Configurando el reloj
#include <lcd.c>                        //Biblioteca LCD
#org 0x1F00, 0x1FFF void loader16F877(void) {}

int var, var_ant, cont;
/*
var: Nueva entrada
var_ant: Entrada anterior
cont: Contador de cambios
*/

void main(){
   cont = 0;                           //Inicializar conteo en 0
   var_ant = input_a();                //Entrada = Puerto A
   
   lcd_init();                         //Inicializar LCD
   while(1){
      var = input_a();                 //Nueva entrada = Puerto A
      if (var != var_ant && var == 1){ //Si son entradas diferentes y es 1
         cont ++;                      //Se aumenta la cuenta
         }
      var_ant = var;                   //Se actualiza la variable anterior 
      
      lcd_gotoxy(1,1);                 //Colocarse en columna 1, renglón 1
      printf(lcd_putc,"%X",cont);      //Imprimir cuenta en hexadecimal
      lcd_gotoxy(1,2);                 //Colocarse en columna 1, renglón 2
      printf(lcd_putc,"%u",cont);      //Imprimir cuenta en decimal
      delay_ms(300);                   //Retardo de 300ms
        
    }//while
}//main
