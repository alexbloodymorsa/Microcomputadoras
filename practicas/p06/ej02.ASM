processor 16f877
include<p16f877.inc>

VAL equ 0X20
SAL0 equ B'00001111'	;Valor registrado de 1V
SAL1 equ B'00011111'	;Valor registrado de 2V
SAL2 equ B'00101111'	;Valor registrado de 3V
SAL3 equ B'00111111'	;Valor registrado de 4V
SAL4 equ B'01001111'	;Valor registrado de 4.8V

	ORG 0 				;Vector de reset
	GOTO INICIO			;Salto al inicio del programa

	ORG 5 				;Inicio del programa
INICIO: 
	CLRF PORTA			;limpia puerto A
	BSF STATUS,RP0		;cambia a banco 1
	BCF STATUS,RP1
	CLRF TRISD			;Configura puerto D como salida
	MOVLW B'00000000'
	MOVWF ADCON1		;Configura puerto A y E como analogicos y el resultado se almacenara¡ en ADRESH
	BCF STATUS,RP0		;cambia a banco 0
	MOVLW B'11111001'	;W = 11111001
	MOVWF ADCON0		;Configura ADCON0 con W: usara¡ reloj interno, canal 7, DONE, conv.A/D encendido
	CLRF PORTD 			;limpia puerto D
REPITE:
	BSF ADCON0,2  		;prende bit 2 de ADCON0 -> GO: inicia la comparacion
	CALL RETARDO		;llama subrutina de retardo
ESPERA:
	BTFSC ADCON0,2 		;checa bit 2 de ADCON0
	GOTO ESPERA			;Si es 1, regresa a la etiqueta ESPERA
	
	MOVLW SAL4
	SUBWF ADRESH,W
	BTFSS STATUS,C		;ENTRADA < 4.8V?
	GOTO COMP4			;if true: siguiente comparación
	MOVLW 0X05			;else:
	MOVWF PORTD			;SALIDA = 5
	GOTO REPITE			;Comparar de nuevo

COMP4:
	MOVLW SAL3
	SUBWF ADRESH,W
	BTFSS STATUS,C		;ENTRADA < 4V?
	GOTO COMP3			;if true: siguiente comparación
	MOVLW 0X04			;else:
	MOVWF PORTD			;SALIDA = 4
	GOTO REPITE			;Comparar de nuevo

COMP3:
	MOVLW SAL2
	SUBWF ADRESH,W
	BTFSS STATUS,C		;ENTRADA < 3V?
	GOTO COMP2			;if true: siguiente comparación
	MOVLW 0X03			;else:
	MOVWF PORTD			;SALIDA = 3
	GOTO REPITE			;Comparar de nuevo

COMP2:
	MOVLW SAL1
	SUBWF ADRESH,W
	BTFSS STATUS,C		;ENTRADA < 2V?
	GOTO COMP1			;if true: siguiente comparación
	MOVLW 0X02			;else:
	MOVWF PORTD			;SALIDA = 2
	GOTO REPITE			;Comparar de nuevo

COMP1:
	MOVLW SAL0
	SUBWF ADRESH,W
	BTFSS STATUS,C		;ENTRADA < 1V?
	GOTO COMP0			;if true: siguiente comparación
	MOVLW 0X01			;else:
	MOVWF PORTD			;SALIDA = 1
	GOTO REPITE			;Comparar de nuevo

COMP0:
	CLRF PORTD			;SALIDA = 0
	GOTO REPITE			;salta a la etiqueta REPITE


RETARDO
	MOVLW 0X30 			;W = 30
	MOVWF VAL			;VAL = W
LOOP:
	DECFSZ VAL 			;decrementa en 1 a VAL, si es cero salta
	GOTO LOOP			;VAL != 0, salta a la etiqueta LOOP
	RETURN				;VAL = 0, regresa al flujo original, acaba subrutina

	END