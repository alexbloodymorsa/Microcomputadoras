PROCESSOR p16f877
INCLUDE <p16f877.inc>

J equ H'26'			;localidad del primer numero
K equ H'27'			;localidad del segundo numero
C1 equ H'28'		;localidad del valor del carry
R1 equ H'29'		;localidad del resultado de la suma

		ORG 0
		GOTO INICIO

		ORG 5
INICIO: MOVF J,W 		;inicio de programa: se mueve num1 a W
		ADDWF K,0 		;se suma W y K y se almacena en W
		MOVWF R1 		;se mueve W a R1
		BTFSC 03H,0 	;se hace un salto si la bandera de carry es 0
		BSF C1,0 		;si no hay salto, carry es 1 y C1 se hace 1
		BCF C1,0 		;si hay salto, carry es 0 y C1 se hace 0
		GOTO INICIO		;se hace un salto a la etiqueta inicio
		END 
