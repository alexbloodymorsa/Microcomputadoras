processor 16f877
include<p16f877.inc>

VAR EQU 0X20 ;Variable de control

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

RECIBE:
	BTFSS PIR1,RCIF		;Bandera de recepci�n completa
	GOTO RECIBE			;Esperar recepci�n

	MOVF RCREG,W		
	MOVWF VAR			;Control = recepci�n

	MOVLW 0x30
	SUBWF VAR,W			;Control == 0x30??
	BTFSC STATUS,Z		;Si son iguales ->
	BCF PORTB,0			;Salida = 0
	MOVLW 0x31			
	SUBWF VAR,W			;Control == 0x31??
	BTFSC STATUS,Z		;Si son iguales ->
	BSF PORTB,0			;Salida = 1

	GOTO RECIBE			;Recibir otro dato

END
