PROCESSOR 16F877
INCLUDE <P16F877.INC>

;Valores utilizados para generar el retardo
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 20h
cte2 equ 50h
cte3 equ 60h

estado0 equ 0x00 ;Valor entrada estado 0
estado1 equ 0x01 ;Valor entrada estado 1
estado2 equ 0x02 ;Valor entrada estado 2
estado3 equ 0x03 ;Valor entrada estado 3
estado4 equ 0x04 ;Valor entrada estado 4
estado5 equ 0x05 ;Valor entrada estado 5
estado6 equ 0x06 ;Valor entrada estado 6
estado7 equ 0x07 ;Valor entrada estado 7
estado8 equ 0x08 ;Valor entrada estado 8

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
	CLRF TRISC		;Configura puerto B como salida
	BCF STATUS,RP0 	;Cambia al banco 
	
LOOP:
	MOVLW estado0		
	XORWF PORTA,W	
	BTFSC STATUS,Z 	;PORTA == estado0?
	GOTO ECERO		;if true: Realizar estado 0
	
	MOVLW estado1
	XORWF PORTA,W
	BTFSC STATUS,Z	;PORTA == estado1?
	GOTO EUNO		;if true: Realizar estado 1
	
	MOVLW estado2
	XORWF PORTA,W
	BTFSC STATUS,Z 	;PORTA == estado2?
	GOTO EDOS		;if true: Realizar estado 2
	
	MOVLW estado3
	XORWF PORTA,W
	BTFSC STATUS,Z	;PORTA == estado3?
	GOTO ETRES		;if true: Realizar estado 3
	
	MOVLW estado4
	XORWF PORTA,W
	BTFSC STATUS,Z	;PORTA == estado4?
	GOTO ECUATRO	;if true: Realizar estado 4
	
	MOVLW estado5
	XORWF PORTA,W
	BTFSC STATUS,Z	;PORTA == estado5?
	GOTO ECINCO		;if true: Realizar estado 5
	
	MOVLW estado6
	XORWF PORTA,W
	BTFSC STATUS,Z	;PORTA == estado6?
	GOTO ESEIS		;if true: Realizar estado 6
	
	MOVLW estado7
	XORWF PORTA,W
	BTFSC STATUS,Z	;PORTA == estado7?
	GOTO ESIETE		;if true: Realizar estado 7
	
	MOVLW estado8
	XORWF PORTA,W
	BTFSC STATUS,Z	;PORTA == estado8?
	GOTO EOCHO		;if true: Realizar estado 8
	GOTO LOOP		;Regresar al loop

;Para M1 = PARO y M2 = PARO
ECERO:
	CLRF PORTB		;PORTB = 0
	CLRF PORTC		;PORTC = 0
	CALL RETARDO	;Se llama el retardo
	GOTO LOOP		;Se vuelve a leer entrada

;Para M1 = PARO y M2 = HORARIO
EUNO:
	MOVLW 0X04
	MOVWF PORTC		;PORTC = 0100
	MOVLW 0X08		
	MOVWF PORTB		;PORTB = 1000
	CALL RETARDO 	;Se llama el retardo
	GOTO LOOP 		;Se vuelve a leer entrada

;Para M1 = PARO y M2 = ANTI-HORARIO	
EDOS:
	MOVLW 0X04
	MOVWF PORTC		;PORTC = 0100
	MOVWF PORTB		;PORTB = 0100
	CALL RETARDO 	;Se llama el retardo
	GOTO LOOP 		;Se vuelve a leer entrada

;Para M1 = HORARIO y M2 = PARO	
ETRES:
	MOVLW 0X02
	MOVWF PORTC		;PORTC = 0010
	MOVWF PORTB		;PORTB = 0010
	CALL RETARDO 	;Se llama el retardo
	GOTO LOOP 		;Se vuelve a leer entrada

;Para M1 = ANTI-HORARIO y M2 = PARO
ECUATRO:
	MOVLW 0X02
	MOVWF PORTC		;PORTC = 0010
	MOVLW 0X01
	MOVWF PORTB		;PORTB = 0001
	CALL RETARDO 	;Se llama el retardo
	GOTO LOOP 		;Se vuelve a leer entrada

;Para M1 = HORARIO y M2 = HORARIO
ECINCO:
	MOVLW 0X06
	MOVWF PORTC		;PORTC = 0110
	MOVLW 0X0A
	MOVWF PORTB		;PORTB = 1010
	CALL RETARDO 	;Se llama el retardo
	GOTO LOOP 		;Se vuelve a leer entrada

;Para M1 = ANTI-HORARIO y M2 = ANTI-HORARIO
ESEIS:
	MOVLW 0X06
	MOVWF PORTC		;PORTC = 0110
	MOVLW 0X05		
	MOVWF PORTB		;PORTB = 0101
	CALL RETARDO 	;Se llama el retardo
	GOTO LOOP 		;Se vuelve a leer entrada

;Para M1 = HORARIO y M2 = ANTI-HORARIO
ESIETE:
	MOVLW 0X06
	MOVWF PORTC		;PORTC = 0110
	MOVWF PORTB		;PORTB = 0110
	CALL RETARDO 	;Se llama el retardo
	GOTO LOOP 		;Se vuelve a leer entrada

;Para M1 = ANTI-HORARIO y M2 = HORARIO	
EOCHO:
	MOVLW 0X06
	MOVWF PORTC 	;PORTC = 0110
	MOVLW 0X09
	MOVWF PORTB		;PORTB = 1001
	CALL RETARDO 	;Se llama el retardo
	GOTO LOOP 		;Se vuelve a leer entrada

;Subrutina para el retardo
RETARDO
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