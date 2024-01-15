processor 16f877
include<p16f877.inc>

VAL equ 0X20

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
	MOVF ADRESH,W 		;Si es 0, W = ADRESH
	MOVWF PORTD			;PORTD = W
	GOTO REPITE			;salta a la etiqueta REPITE
RETARDO
	MOVLW 0X30 			;W = 30
	MOVWF VAL			;VAL = W
LOOP:
	DECFSZ VAL 			;decrementa en 1 a VAL, si es cero salta
	GOTO LOOP			;VAL != 0, salta a la etiqueta LOOP
	RETURN				;VAL = 0, regresa al flujo original, acaba subrutina

	END
