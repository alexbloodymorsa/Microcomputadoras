#include <16F877.h>                     //Biblioteca PIC16F877A
#fuses HS,NOWDT,NOPROTECT,NOLVP
#use delay(clock=20000000)              //Configurando el reloj
#include <lcd.c>                        //Biblioteca de LCD
#org 0x1F00, 0x1FFF void loader16F877(void) {}

void main() {
    lcd_init();                         //Incializa el display de crisital líquido
    while( TRUE ) {
        lcd_gotoxy(1,1);                //Colocarse en columna 1, renglón 1
        printf(lcd_putc," UNAM \n ");   //Imprimir en LCD
        lcd_gotoxy(1,2);                //Colocarse en columna 1, renglón 2
        printf(lcd_putc," FI \n ");     //Imprimir en LCD
        delay_ms(300);                  //Retardo de 300ms
    }
}