PROCESSOR p16f877
INCLUDE <p16f877.inc>

K equ H'26'		;localidad de sumando
L equ H'27'		;localidad de sumando
M equ H'28'		;localidad de resultado

		ORG 0
 		GOTO INICIO 	;salto a inicio de programa

 		ORG 5
INICIO: MOVF K,W		;se mueve K a W
 		ADDWF L,0		;se suma K con L en W
 		MOVWF M			;se almacena el resultado en M
 		GOTO INICIO		;se regresa al  inicio
 		END