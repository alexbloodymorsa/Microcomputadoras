processor 16f877
include<p16f877.inc>

VAR EQU 0X20		;Variable de control
DATO EQU 0X24		;Dato de salida

;Valores para el retardo
valor1 equ h'21
valor2 equ h'22
valor3 equ h'23
cte1 equ 20h
cte2 equ 50h
cte3 equ 60h


CONT equ 0X25 ;Contador para número de rotaciones

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

RECIBE:
	BTFSS PIR1,RCIF		;Bandera de recepción completa
	GOTO RECIBE			;Esperar la recepción

	MOVF RCREG,W
	MOVWF VAR			;Control = Recepción

	MOVLW 0x44
	SUBWF VAR,W
	BTFSC STATUS,Z		;Si Control = 0x44 "d"
	GOTO DER			;Rotación a la derecha
	MOVLW 0x64
	SUBWF VAR,W
	BTFSC STATUS,Z		;Si Control = 0x64 "D"
	GOTO DER			;Rotación a la derecha
	MOVLW 0x49
	SUBWF VAR,W
	BTFSC STATUS,Z		;Si Control = 0x49 "i"
	GOTO IZQ			;Rotación a la izquierda
	MOVLW 0x69
	SUBWF VAR,W
	BTFSC STATUS,Z		;Si Control = 0x69 "I"
	GOTO IZQ			;Rotación a la izquierda
	GOTO RECIBE			;Recibir otro dato

DER						;Rotación a la derecha
	MOVLW 0X80
	MOVWF DATO			;Dato = 1000 0000
	MOVLW 0X08
	MOVWF CONT			;Contador = 8 rotaciones
LOOPD
	MOVF DATO,W
	MOVWF PORTB			;Salida = Dato
	CALL retardo		;Se llama al retardo
	BCF STATUS,C		;Se limpia el acarreo
	RRF DATO			;Rotación a la derecha
	DECFSZ CONT			;Contador == 0?
	GOTO LOOPD			;Si no es continuar el loop
	GOTO RECIBE			;Si es cero volver a recibir

IZQ						;Rotación a la izquierda
	MOVLW 0X01
	MOVWF DATO			;Dato = 0000 0001
	MOVLW 0X08
	MOVWF CONT			;Contador = 8 rotaciones
LOOPI
	MOVF DATO,W
	MOVWF PORTB			;Salida = Dato
	CALL retardo		;Se llama al retardo
	BCF STATUS,C		;Se limpia el acarreo
	RLF DATO			;Rotación a la izquierda
	DECFSZ CONT			;Contador == 0?
	GOTO LOOPI			;Si no es cero continuar el loop
	GOTO RECIBE			;Si es cero volver a recibir

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