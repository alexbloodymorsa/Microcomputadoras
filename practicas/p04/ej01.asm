PROCESSOR 16F877
INCLUDE <P16F877.INC>

	ORG 0 ;Vector de reset
	GOTO INICIO
	
	ORG 5
INICIO: 
	CLRF PORTA 		; Limpia PORTA
	BSF STATUS,RP0 	; Cambia a banco 1
	BCF STATUS,RP1
	MOVLW 06H 		;Define puertos A y E como digitales
	MOVWF ADCON1
	MOVLW H'3F' 	;Configura puerto A como entrada
	MOVWF TRISA
	CLRF TRISB		;Configura puerto B como salida
	BCF STATUS,RP0 	;Cambia al banco 
LOOP:				;Inicia Loop
	BTFSC PORTA,0	;Checa el primer bit del puerto A
	GOTO CERO		;Si es cero va a CERO
	MOVLW 0XFF		;Si no es cero:
	MOVWF PORTB		;puertoB = FF
	GOTO LOOP		;Regresa al Loop
CERO:
	CLRF PORTB		;puertoB = 00
	GOTO LOOP		;Regresa al Loop
	END
	
	