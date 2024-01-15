PROCESSOR p16f877
INCLUDE <p16f877.inc>

K equ H'26'		;localidad sumando
L equ H'27'		;localidad resultado

		ORG 0
 		GOTO INICIO		;salto a inicio de programa
 		
		ORG 5
INICIO: MOVLW H'05'		;se pone 05 en W
 		ADDWF K,0		;suma de K con W
 		MOVWF L			;se mueve el resultado a L
	 	GOTO INICIO		;se regresa al inicio
 		END