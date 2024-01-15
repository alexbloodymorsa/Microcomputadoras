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
	BCF TXSTA,SYNC		;Comunicaci�n s�ncrona
	BSF TXSTA,TXEN		;Activa transmisi�n
	
	BCF STATUS,RP0		;Se cambia al banco 00
	
	BSF RCSTA,SPEN		;Habilita puerto serie
	BSF RCSTA,CREN		;Recepci�n sencilla

RECIBE:					;Recepci�n de un dato
	BTFSS PIR1,RCIF		;Bandera recepci�n completa
	GOTO RECIBE			;Esperar a la informaci�n

	MOVF RCREG,W		
	MOVWF TXREG			;Transmisi�n = Recepci�n
	MOVWF PORTB			;Salida = Transmisi�n

	BSF STATUS,RP0		;Se cambia al banco 01

TRASMITE:				;Transmisi�n de dato
	BTFSS TXSTA,TRMT	;Bandera transmisi�n completa
	GOTO TRASMITE		;Esperar transmisi�n
	BCF STATUS,RP0		;Se cambia al banco 00
	GOTO RECIBE			;Volver a recibir

END