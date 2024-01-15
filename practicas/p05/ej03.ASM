PROCESSOR 16F877
INCLUDE <P16F877.INC>

;Valores y constantes para el retardo
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 0Ah
cte2 equ 10h
cte1M equ 05h		;Constante para 1ms
cte15M equ 0Eh		;Constante para 1.5ms
cte2M equ 18h		;Constante para 2ms
cte19M equ 0XB2 	;Constante para 19ms
cte185M equ 0XA9	;Constante para 18.5ms
cte18M equ 0X9F		;Constante para 18ms

estado0 equ 0x01	;Valor entrada estado 0
estado1 equ 0x02	;Valor entrada estado 1
estado2 equ 0x04	;Valor entrada estado 2

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
	CLRF TRISC		;Configura el puerto C como salida
	BCF STATUS,RP0 	;Cambia al banco 
	
LOOP:
	MOVLW estado0
	XORWF PORTA,W
	BTFSC STATUS,Z	;PORTA == estado0?
	GOTO ECERO		;if true: realizar estado 0
	
	MOVLW estado1
	XORWF PORTA,W
	BTFSC STATUS,Z	;PORTA == estado1?
	GOTO EUNO		;if true: realizar estado 1
	
	MOVLW estado2
	XORWF PORTA,W
	BTFSC STATUS,Z	;PORTA == estado2?
	GOTO EDOS		;if true: realizar estado 2
	GOTO LOOP		;Checar la entrada de nuevo

;Rotación hacia la izquierda (0°)	
ECERO:
	MOVLW 0X01
	MOVWF PORTC		;PORTC = 1
	CALL RETARDO1M	;1ms en uno
	CLRF PORTC		;PORTC = 0
	CALL RETARDO19M ;19ms en cero
	GOTO LOOP		;Checar la entrada de nuevo

;Rotación central (90°)
EUNO:
	MOVLW 0X01
	MOVWF PORTC		;PORTC = 1
	CALL RETARDO15M	;1.5ms en uno 
	CLRF PORTC		;PORTC = 0
	CALL RETARDO185M;18.5ms en cero
	GOTO LOOP		;Checar la entrada de nuevo

;Rotación hacia la derecha (180°)	
EDOS:
	MOVLW 0X01
	MOVWF PORTC		;PORTC = 1
	CALL RETARDO2M	;2ms en uno
	CLRF PORTC		;PORTC = 0
	CALL RETARDO18M ;18ms en cero
	GOTO LOOP		;Checar la entrada de nuevo

;Retardo para 1ms
RETARDO1M
	MOVLW cte1
	MOVWF valor1
tres1M
	MOVLW cte2
	MOVWF valor2
dos1M 
	MOVLW cte1M
	MOVWF valor3
uno1M 
	DECFSZ valor3
	GOTO uno1M
	DECFSZ valor2
	GOTO dos1M
	DECFSZ valor1
	GOTO tres1M
	RETURN

;Retardo para 1.5ms
RETARDO15M
	MOVLW cte1
	MOVWF valor1
tres15M
	MOVLW cte2
	MOVWF valor2
dos15M 
	MOVLW cte15M
	MOVWF valor3
uno15M 
	DECFSZ valor3
	GOTO uno15M
	DECFSZ valor2
	GOTO dos15M
	DECFSZ valor1
	GOTO tres15M
	RETURN

;Retardo para 2ms
RETARDO2M
	MOVLW cte1
	MOVWF valor1
tres2M
	MOVLW cte2
	MOVWF valor2
dos2M 
	MOVLW cte2M
	MOVWF valor3
uno2M 
	DECFSZ valor3
	GOTO uno2M
	DECFSZ valor2
	GOTO dos2M
	DECFSZ valor1
	GOTO tres2M
	RETURN

;Retardo para 19ms
RETARDO19M
	MOVLW cte1
	MOVWF valor1
tres19M
	MOVLW cte2
	MOVWF valor2
dos19M 
	MOVLW cte19M
	MOVWF valor3
uno19M 
	DECFSZ valor3
	GOTO uno19M
	DECFSZ valor2
	GOTO dos19M
	DECFSZ valor1
	GOTO tres19M
	RETURN

;Retardo para 18.5ms
RETARDO185M
	MOVLW cte1
	MOVWF valor1
tres185M
	MOVLW cte2
	MOVWF valor2
dos185M 
	MOVLW cte185M
	MOVWF valor3
uno185M 
	DECFSZ valor3
	GOTO uno185M
	DECFSZ valor2
	GOTO dos185M
	DECFSZ valor1
	GOTO tres185M
	RETURN

;Retardo para 18ms
RETARDO18M
	MOVLW cte1
	MOVWF valor1
tres18M
	MOVLW cte2
	MOVWF valor2
dos18M 
	MOVLW cte18M
	MOVWF valor3
uno18M 
	DECFSZ valor3
	GOTO uno18M
	DECFSZ valor2
	GOTO dos18M
	DECFSZ valor1
	GOTO tres18M
	RETURN
	
	END