processor p16f877
include <p16f877.inc>

valor1 equ h'21'		;Valor 1 para el retardo
valor2 equ h'22'		;Valor 2 para el retardo
valor3 equ h'23'		;Valor 3 para el retardo 
cte1 equ 0xFF			;constante 1 para tiempo del retardo
cte2 equ 0x90			;constante 2 para tiempo del retardo
cte3 equ 60h			;cosntante 3 para tiempo del retardo
estado1 equ 41h			;Valor para prender Verde1 y Rojo2
estado2 equ 21h			;Valor para prender Amarillo1 y Rojo2
estado3 equ 14h			;Valor para prender Rojo1 y Verded2
estado4 equ 12h			;Valor para prender Rojo1 y Amarillo2
 
	ORG 0
	GOTO INICIO
 	ORG 5
INICIO:
	BSF STATUS,RP0
 	BCF STATUS,RP1		;Se selecciona el banco 01
 	MOVLW H'0'
 	MOVWF TRISB			;portb = salida
 	BCF STATUS,RP0		;Se selecciona el banco 00
 	CLRF PORTB			;portb = 00
loop2:
	MOVLW estado1		
	MOVWF PORTB			;portb = estado1 = V1 y R2 prendidos
 	CALL retardo		;Se llama al retardo
	MOVLW estado2
	MOVWF PORTB			;portb = estado2 = A1 y R2 prendidos
 	CALL retardo		;Se llama al retardo
	MOVLW estado3
	MOVWF PORTB			;portb = estado3 = R1 y V2
 	CALL retardo		;Se llama al retardo
	MOVLW estado4
	MOVWF PORTB			;portb = estado4 = R1 y A2
 	CALL retardo		;Se llama el retardo
 	GOTO loop2			;Regreso al primer estado
retardo:				;Instrucciones para el retardo
	MOVLW cte1
 	MOVWF valor1		;valor1 = cte1
tres:
	MOVLW cte2
	MOVWF valor2		;valor2 = cte2
dos: 
	MOVLW cte3
	MOVWF valor3		;valor3 = cte3
uno:
	DECFSZ valor3		;Decrementa hasta que valor3 = 0
 	GOTO uno
	DECFSZ valor2		;Decrementa hasta que valor2 = 0
	GOTO dos
	DECFSZ valor1		;Decrementa hasta que valor1 = 0
	GOTO tres
	RETURN				;Regresar
	END