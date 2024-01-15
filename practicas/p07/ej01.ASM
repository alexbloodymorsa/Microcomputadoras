processor 16f877
include<p16f877.inc>

	ORG 0
	GOTO inicio
	ORG 5

inicio
	BSF STATUS,RP0
	BCF STATUS,RP1 		;Se cambia al banco 01
	CLRF TRISB			;Puerto B como salida
	BSF TXSTA,BRGH		;Cambia bandera BRGH		
	MOVLW D'129'
	MOVWF SPBRG			;Baud rate = 9600
	BCF TXSTA,SYNC		;Comunicación síncrona
	BSF TXSTA,TXEN		;Activa transmisión
	
	BCF STATUS,RP0		;Se cambia al banco 00
	
	BSF RCSTA,SPEN		;Habilita puerto serie
	BSF RCSTA,CREN		;Recepción sencilla

RECIBE:					;Recepción de un dato
	BTFSS PIR1,RCIF		;Bandera recepción completa
	GOTO RECIBE			;Esperar a la información

	MOVF RCREG,W		
	MOVWF TXREG			;Transmisión = Recepción
	MOVWF PORTB			;Salida = Transmisión

	BSF STATUS,RP0		;Se cambia al banco 01

TRASMITE:				;Transmisión de dato
	BTFSS TXSTA,TRMT	;Bandera transmisión completa
	GOTO TRASMITE		;Esperar transmisión
	BCF STATUS,RP0		;Se cambia al banco 00
	GOTO RECIBE			;Volver a recibir

END