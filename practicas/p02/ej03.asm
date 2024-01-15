PROCESSOR p16f877
INCLUDE <p16f877.inc> 

MENOR equ H'40'			;Registro donde se almacena el mínimo
ULTIMO equ 0x2F			;Registro donde se alm
INDICE equ H'41'		;Índice del registro con valor mínimo
CONT equ H'42'			;Conteo del número de registros a comparar
W2 equ H'43'			;Registro de variable temporal
ULTIMOCOMP equ 0X30		;Dirección del último registro a ordenar

	ORG 0
 	GOTO INICIO 
 	ORG 5

INICIO: 
	BCF STATUS,RP1		;Se hace cero el bit 1 del banco
	BSF STATUS,RP0		;Se hace uno el bit 0 del banco
	MOVLW 0X20			
	MOVWF FSR			;FSR = 0X20
	MOVWF CONT			;Se mueve a contador el valor inicial
ANTES:
	MOVF INDF,W			;El valor de la localidad FSR se guarda en W
	MOVWF MENOR			;MENOR = INDF
	MOVF FSR,W			;La dirección de FSR se guarda en W
	MOVWF INDICE		;INDICE = FSR
COMP:
	MOVF MENOR,W		;Se realiza la comparación entre dos números utilizando la resta
	INCF FSR			;El valor menor se almacena en W
	SUBWF INDF,0		;INDF-W:NUM2-NUM1
	BTFSS STATUS,C		;Si el carry es cero NUM2 es menor
	GOTO ACTUALIZAR		;Si carry es cero -> se actualiza el menor
	GOTO FINAL			;Si carry es uno -> checar valor de FSR
ACTUALIZAR:				;Actualizar valor del menor y su índice
	MOVF INDF,W
	MOVWF MENOR			;MENOR = INDF
	MOVF FSR,W
	MOVWF INDICE		;INDICE = FSR
	 
FINAL:					;Verificar que no sea el último elemento
	MOVLW ULTIMO		
	XORWF FSR,W			;Haciendo comparación: FSR == ULTIMO
	BTFSC STATUS,Z		
	GOTO SWAP			;Si son iguales realizar el swap
	GOTO COMP			;Si no son iguales seguir comparando

SWAP:					;Realiza el swap del mínimo con el primer valor
	MOVF CONT,W
	MOVWF FSR			;FSR = CONT
	MOVF INDF,W 		
	MOVWF W2			;W2 = INDF
	MOVF INDICE,W
	MOVWF FSR			;FSR = INDICE
	MOVF W2,W
	MOVWF INDF			;INDF = W2

	MOVF CONT,W			
	MOVWF FSR			;FSR = CONT
	MOVF MENOR,W
	MOVWF INDF			;INDF = MENOR
	
	INCF CONT			;Incrementar el contador, se tiene un elemento menos
	MOVLW ULTIMO		
	XORWF CONT,W		;Realizar comparación CONT == ULTIMO
	BTFSC STATUS,Z		;Se realiza para saber si ya se ordenó todo
	GOTO $				;Si son iguales se acaba el programa
						;De lo contrario se realiza lo siguiente
	MOVF CONT,W			
	MOVWF FSR			;FSR = CONT
	GOTO ANTES			;Volver a buscar el mínimo para acomodarlo
END