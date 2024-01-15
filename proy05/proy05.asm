processor 16f877
include<p16f877.inc>

VAR EQU 0X20 			;Valor de control
CONTADORL EQU 0X21	
CONTADORH EQU 0X22


	ORG 0
	GOTO inicio

	ORG 4				;Vector interrupciones
	GOTO INTERRUPCIONES

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

	BSF PIE1,TMR1IE 	;Se activan interrupcion por desbordamiento de Timer1
	
	BCF STATUS,RP0		;Se cambia al banco 00
	
	BSF RCSTA,SPEN		;Habilita puerto serie
	BSF RCSTA,CREN		;Recepción sencilla

	MOVLW B'00110001' 	
	MOVWF T1CON			;Predivisor de 8 flancos, función de temporizador y Timer1 ON
	BSF INTCON, PEIE	;Habilita interrupciones de segundo bloque
	BSF INTCON, GIE		;Habilita interrupciones generales
	CLRF TMR1H			;Inicializa parte alta TMR1
	CLRF TMR1L			;Inicializa parte baja TMR1
	CLRF CONTADORL		;ContadorL en cero
	CLRF CONTADORH		;ContadorH en cero
	BCF INTCON, TMR1IF	;Limpia bandera desbordamiento

RECIBE:
	BTFSS PIR1,RCIF		;Bandera de recepción completa
	GOTO RECIBE			;Esperar recepción

	MOVF RCREG,W
	MOVWF VAR			;Control = Recepción

	MOVLW 0x53
	SUBWF VAR,W
	BTFSC STATUS,Z		;Si control = 0x53 "S"
	GOTO STOP			;Entonces parar
	MOVLW 0x41
	SUBWF VAR,W
	BTFSC STATUS,Z		;Si control = 0x41 "A"
	GOTO ADELANTE		;Entonces avanzar
	MOVLW 0x54
	SUBWF VAR,W
	BTFSC STATUS,Z		;Si control = 0x54 "T"
	GOTO TRAS			;Entonces retroceder
	MOVLW 0x44
	SUBWF VAR,W
	BTFSC STATUS,Z		;Si control = 0x44 "D"
	GOTO DER			;Mover a la derecha
	MOVLW 0x49
	SUBWF VAR,W
	BTFSC STATUS,Z		;Si control = 0x49 "I"
	GOTO IZQ			;Mover a la izquierda
	GOTO RECIBE			;Recibir otro dato

STOP					;Parar ambos motores
	CLRF PORTC			;C = 0
	CLRF PORTB			;B = 0
	GOTO RECIBE 		;Recibir otro dato

ADELANTE				;Horario ambos motores
	MOVLW 0X06
	MOVWF PORTC			;C = 0x06
	MOVLW 0X0A
	MOVWF PORTB			;B =  0x0A
	GOTO RECIBE			;Recibir otro dato

TRAS					;Antihorario ambos motores
	MOVLW 0X06
	MOVWF PORTC			;C = 0x06
	MOVLW 0X05
	MOVWF PORTB			;B = 0x05
	GOTO RECIBE			;Recibir otro dato

DER						;Dirección a la derecha
	MOVLW 0X06
	MOVWF PORTC			;C = 0x06
	MOVLW 0X09
	MOVWF PORTB			;C = 0x09
	GOTO RECIBE			;Recibir otro dato

IZQ						;Dirección a la izquierda
	MOVLW 0X06
	MOVWF PORTC			
	MOVWF PORTB			;B = C = 0x06
	GOTO RECIBE			;Recibir otro dato

INTERRUPCIONES:
	BTFSS PIR1, TMR1IF	;Checar bandera de desbordamiento TMR1
	GOTO SAL_NO_FUE_TMR1;Si fue otra interrupción salir

	MOVLW 0XFF
	SUBWF CONTADORL, W	;ContadorL - FF
	BTFSS STATUS, Z		;Si el resultado es 0
	GOTO INC_CL			;Checar el contador
	INCF CONTADORH		;Incrementa contador H
	CLRF CONTADORL		;Limpia contador L
	GOTO COMPARACION	;Sigue la comparación

INC_CL:
	INCF CONTADORL		;Incrementa ContadorL
COMPARACION:
	MOVLW 0X03
	SUBWF CONTADORH, W	;ContadorH - 0x03
	BTFSS STATUS, Z		;Si el resultado es cero
	GOTO SAL_INT		;Sale de la interrupción
	MOVLW 0X5A
	SUBWF CONTADORL, W	;ContadorL - 0x5A
	BTFSS STATUS, Z		;Si el resultado es cero
	GOTO SAL_INT		;Sale de la interrupción
	CLRF PORTC			;Limpia salida C
	CLRF PORTB			;Limpia salida B
	GOTO $				;Loop infinito

SAL_INT:
	BCF PIR1, TMR1IF	;Limpia bandera de interrupción
SAL_NO_FUE_TMR1:
	RETFIE				;Regresa de la interrupción

END