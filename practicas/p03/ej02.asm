processor p16f877
include <p16f877.inc>

valor1 equ h'21'		;Valor 1 para el retardo
valor2 equ h'22'		;Valor 2 para el retardo 
valor3 equ h'23'		;Valor 3 para el retardo
cte1 equ 80h			;constante 1 para lo que se tarda el retardo
cte2 equ 50h			;constante 2 para lo que se tarda el retardo
cte3 equ 60h			;constante 3 para lo que se tarda el retardo
 
	ORG 0
	GOTO INICIO
 	ORG 5
INICIO:
	BSF STATUS,RP0
 	BCF STATUS,RP1		;Se selecciona el banco 01
 	MOVLW H'0'
 	MOVWF TRISB			;portb = salida
 	BCF STATUS,RP0		;Se selecciona el banco 00
 	CLRF PORTB			;El valor de portb es cero
loop2:
	MOVLW 0x01			;Se coloca 01 en W
	MOVWF PORTB 		;Se mueve el valor de W a PORTB
	CALL retardo		;Se llama el retardo
ROTA:	
	BTFSS PORTB,7 		;Se revisa el valor del bit 7 de M, si es 1 hay un salto
	GOTO SIGUE 			;Si el bit 7 de M es 0, salta a la etiqueta sigue
	GOTO loop2			;Si el bit 7 de M es 1, salta al inicio del programa
SIGUE:	
	RLF PORTB 			;Rotan los bits en M hacia la izquierda usando el carry
	CALL retardo		;Se llama el retardo
	GOTO ROTA 			;Salta a la etiqueta rota

retardo:				;Instrucciones para generar el retardo
	MOVLW cte1
 	MOVWF valor1		;valor1 = cte1
tres:
	MOVLW cte2
	MOVWF valor2		;valor2 = cte2
dos: 
	MOVLW cte3
	MOVWF valor3		;valor3 = cte3
uno:
	DECFSZ valor3		;Decrementa hasta que valor 3 sea cero
 	GOTO uno
	DECFSZ valor2		;Decrementa hasta que valor 2 sea cero
	GOTO dos
	DECFSZ valor1		;Decrementa hasta que valor 1 sea cero
	GOTO tres
	RETURN				;Se acaba el retardo
	END