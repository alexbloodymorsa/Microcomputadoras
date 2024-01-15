processor 16f877
include<p16f877.inc>

APUN EQU 0X20
DATO EQU 0X21

;Valores para el retardo
valor1 equ h'21
valor2 equ h'22
valor3 equ h'23
cte1 equ 20h
cte2 equ 50h
cte3 equ 60h

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

REP 
	CLRF APUN			;Apuntador = 0
CICLO 
	CALL TEXTO			;Se apunta al texto
	MOVWF DATO			
	SUBLW "$"			
	BTFSC STATUS,Z		;Verificando que no se haya llegado al final
	GOTO REP			;Si es el final se repite
	CALL TRANSMITE		;Si no es el final se transmite
	INCF APUN,1			;Se apunta a la siguiente letra
	GOTO CICLO			;Se repite el ciclo
	
TRANSMITE:
	MOVF DATO,W		
	MOVWF TXREG			;Transmisión = Dato
TRA
	BSF STATUS,RP0		;Se cambia al banco 01
ESP	
	BTFSS TXSTA,TRMT	;Bandera de transmisión
	GOTO ESP			;Esperar transmisión
	CALL retardo		;Se llama el retardo
	BCF STATUS,RP0		;Se cambia al banco 00
	RETURN

TEXTO
	MOVF APUN,W			
	ADDWF PCL,1		;Se mueve a la siguiente letra del texto
	DT "HOLA UNAM",0X0D,0X0A,"$" ; Texto a mostrar

;Subrutina para el retardo
retardo 
	MOVLW cte1
 	MOVWF valor1
tres 
	MOVLW cte2
	MOVWF valor2
dos 
	MOVLW cte3
	MOVWF valor3
uno 
	DECFSZ valor3
 	GOTO uno
	DECFSZ valor2
	GOTO dos
	DECFSZ valor1
	GOTO tres
	RETURN

END