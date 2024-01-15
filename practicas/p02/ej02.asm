PROCESSOR p16f877
INCLUDE <p16f877.inc> 

MENOR equ H'40'			;Registro donde se almacena el mínimo
TF equ H'41'			;Registro para 3F (último registro a checar)

	ORG 0
 	GOTO INICIO 
 	ORG 5

INICIO: 
	BCF STATUS,RP1		;Se hace cero el bit 1 del banco
	BSF STATUS,RP0		;Se hace uno el bit 0 del banco
	MOVLW 0X20			
	MOVWF FSR			;FSR = 0X20
	MOVF INDF,W			;El valor de la localidad 0X20 se guarda en W
	MOVWF MENOR			;Se guarda el valor de W en MENOR

COMP:					;Se realiza la comparación entre dos números utilizando la resta
	MOVF MENOR,W		;El valor menor se almacena en W
	INCF FSR			;Se incrementa FSR en uno
	SUBWF INDF,0		;INDF-W:NUM2-NUM1
	BTFSS STATUS,C		;Si el carry es cero NUM2 es menor
	GOTO ACTUALIZAR		;Si carry es cero -> se actualiza el menor
	GOTO TRESF			;Si carry es uno -> checar valor de FSR

ACTUALIZAR:				;Actualizar el valor del menor
	MOVF INDF,W			
	MOVWF MENOR			;MENOR = INDF

TRESF:					;Checar que no se haya llegado a localidad 3F
	MOVF TF,W			
	XORWF FSR,W			;Se genera la comparación 3F == FSR
	BTFSC STATUS,Z		
	GOTO $				;Si son iguales -> final del programa
	GOTO COMP			;Si no son iguales -> seguir comparando
	END