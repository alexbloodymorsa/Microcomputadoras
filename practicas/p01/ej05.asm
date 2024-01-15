PROCESSOR p16f877
INCLUDE <p16f877.inc>

M equ H'20'			;localidad del resultado
DIEZ equ H'22'		;localidad que guarda el valor 0A
V equ H'23'			;localidad que guarda el valor 20
W2 equ H'24'		;localidad auxiliar

		ORG 0
		CLRF M 				;se limpia el valor en M
		GOTO INICIO			;salta al inicio de programa

		ORG 5
INICIO: 					;bloque que verifica si se llegó a 20 para volver al 0
		MOVF M,W 			;inicio de programa: se mueve M a W
		XORWF V,W 			;W xor V y se almacena el resultado en W
		BTFSS 03H,2 		;salta si la bandera z es 1 (como resultado del xor)
		GOTO INCREMENTO 	;si z es 0, salta a incremento
		CLRF M 				;si z es 1, se limpia M
		GOTO INICIO			;salta al inicio del programa 

INCREMENTO:	 				;bloque que verifica si el siguiente numero 10 o 20
		MOVF M,W 			;mueve M a W
		ADDLW 01 			;incrementa en 1 a W
		MOVWF W2			;mueve W a W2
		BCF W2,4 			;covierte en 0 al bit 4 de W2
		MOVF W2,W 			;mueve W2 a W
		XORWF DIEZ,W 		;W xor 0A y se almacena el resultado en W
		BTFSS 03H,2 		;salta si la bandera z es 1 (como resultado del xor)
		GOTO NODIEZ 		;si z es 0, salta a sidiez

SIDIEZ:						;bloque que aumenta 7 a 09 y 19 para obtener 10 y 20
		MOVLW 07 			;mueve 07 a W
		ADDWF M 			;suma W y M y almacena el resultado en M
		GOTO INICIO 		;salta al inicio del programa

NODIEZ:  					;bloque que incrementa el numero actual
		INCF M 				;se incrementa M
		GOTO INICIO 		;salta al inicio del programa
		END

