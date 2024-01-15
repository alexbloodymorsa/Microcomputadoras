processor 16f877
include<p16f877.inc>

VAL equ 0X20			;Valor para el retardo
VE1 equ 0X21			;Valor para primer potenciómetro
VE2 equ 0X22			;Valor para segundo potenciómetro
VE3 equ 0X23			;Valor para tercer potenciómetro

	ORG 0 				;Vector de reset
	GOTO INICIO			;Salto al inicio del programa

	ORG 5 				;Inicio del programa
INICIO: 
	CLRF PORTA			;limpia puerto A
	CLRF PORTD 			;limpia puerto D
	BSF STATUS,RP0		;cambia a banco 1
	BCF STATUS,RP1
	CLRF TRISD			;Configura puerto D como salida
	MOVLW B'00000000'
	MOVWF ADCON1		;Configura puerto A y E como analogicos y el resultado se almacenara¡ en ADRESH
	BCF STATUS,RP0		;cambia a banco 0

REPITE:	
	MOVLW B'11101001'	;W = 11101001
	MOVWF ADCON0		;Configura ADCON0 con W: usara¡ reloj interno, canal 5, DONE, conv.A/D encendido
	BSF ADCON0,2  		;prende bit 2 de ADCON0 -> GO: inicia la comparacion
	CALL RETARDO		;llama subrutina de retardo
ESPERA1:
	BTFSC ADCON0,2 		;checa bit 2 de ADCON0
	GOTO ESPERA1		;Si es 1, regresa a la etiqueta ESPERA
	MOVF ADRESH,W 		;Si es 0, W = ADRESH
	MOVWF VE1			;VE1 = W
	
	MOVLW B'11110001'	;W = 11110001
	MOVWF ADCON0		;Configura ADCON0 con W: usara¡ reloj interno, canal 6, DONE, conv.A/D encendido
	BSF ADCON0,2  		;prende bit 2 de ADCON0 -> GO: inicia la comparacion
	CALL RETARDO		;llama subrutina de retardo
ESPERA2:
	BTFSC ADCON0,2 		;checa bit 2 de ADCON0
	GOTO ESPERA2			;Si es 1, regresa a la etiqueta ESPERA
	MOVF ADRESH,W 		;Si es 0, W = ADRESH
	MOVWF VE2			;VE1 = W
	
	MOVLW B'11111001'	;W = 11111001
	MOVWF ADCON0		;Configura ADCON0 con W: usara¡ reloj interno, canal 7, DONE, conv.A/D encendido
	BSF ADCON0,2  		;prende bit 2 de ADCON0 -> GO: inicia la comparacion
	CALL RETARDO		;llama subrutina de retardo
ESPERA3:
	BTFSC ADCON0,2 		;checa bit 2 de ADCON0
	GOTO ESPERA3		;Si es 1, regresa a la etiqueta ESPERA
	MOVF ADRESH,W 		;Si es 0, W = ADRESH
	MOVWF VE3			;VE1 = W
	
	MOVF VE2,W
	SUBWF VE1,W
	BTFSS STATUS,C		;VE1 > VE2
	GOTO COMPNEG		;if false: comparación donde VE1 es menor
	GOTO COMPPOS		;if true: comparación donde VE1 es mayor
COMPPOS:
	MOVF VE3,W
	SUBWF VE1,W
	BTFSS STATUS,C		;VE1 > VE3
	GOTO V3				;if false: VE3 es el mayor
	MOVLW 0X01			;else:
	MOVWF PORTD			;PORTD = 1
	GOTO REPITE			;Realizar la comparación de nuevo
COMPNEG:
	MOVF VE3,W
	SUBWF VE2,W
	BTFSS STATUS,C		;VE2 > VE3
	GOTO V3				;if false: VE3 es el mayor
	MOVLW 0X03			;else:
	MOVWF PORTD			;PORTD = 3
	GOTO REPITE			;Realizar la comparación de nuevo
V3: ;Se realiza cuando VE3 es el mayor
	MOVLW 0X07
	MOVWF PORTD			;PORTD = 7
	GOTO REPITE			;Realizar la comparación de nuevo
	
RETARDO
	MOVLW 0X30 			;W = 30
	MOVWF VAL			;VAL = W
LOOP:
	DECFSZ VAL 			;decrementa en 1 a VAL, si es cero salta
	GOTO LOOP			;VAL != 0, salta a la etiqueta LOOP
	RETURN				;VAL = 0, regresa al flujo original, acaba subrutina

	END