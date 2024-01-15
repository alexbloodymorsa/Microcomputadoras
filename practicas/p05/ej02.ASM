PROCESSOR 16F877
INCLUDE <P16F877.INC>

; Valores para el retardo
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 0Ah
cte2 equ 0Ah
cte3 equ 4Bh

; Valores para ciclo anidado para una vuelta
valorlen equ h'25'
valorrap equ h'26'
cte40 equ 40h
cte08 equ 08h

estado0 equ 0x00 ;Valor entrada estado 0
estado1 equ 0x01 ;Valor entrada estado 1
estado2 equ 0x02 ;Valor entrada estado 2
estado3 equ 0x03 ;Valor entrada estado 3
estado4 equ 0x04 ;Valor entrada estado 4
CONT equ h'24' 	;Contador de vueltas

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
	
LOOP:
	MOVLW estado0
	XORWF PORTA,W
	BTFSC STATUS,Z 	;PORTA == estado0?
	GOTO ECERO		;if true: realiza estado 0
	
	MOVLW estado1
	XORWF PORTA,W
	BTFSC STATUS,Z 	;PORTA == estado1?
	CALL EUNO 		;if true: realiza estado 1
	
	MOVLW estado2
	XORWF PORTA,W
	BTFSC STATUS,Z 	;PORTA == estado2?
	CALL EDOS 		;if true: realiza estado 2
	
	MOVLW estado3
	XORWF PORTA,W
	BTFSC STATUS,Z 	;PORTA == estado3?
	GOTO ETRES 		;if true: realiza estado 3
	
	MOVLW estado4
	XORWF PORTA,W
	BTFSC STATUS,Z 	;PORTA == estado4?
	GOTO ECUATRO 	;if true: realiza estado 4
	GOTO LOOP		;Checar entrada de nuevo

;Motor en paro
ECERO:
	CLRF PORTB		;La salida es cero
	CALL RETARDO	;Se llama a retardo
	GOTO LOOP 		;Checar entrada de nuevo

;Girar en sentido horario
EUNO:
;Se genera un ciclo anidado para llamar al sentido horario varias veces
;Se da una vuelta
	MOVLW cte08
	MOVWF valorlen
ciclolen1 
	MOVLW cte40
	MOVWF valorrap
ciclorap1 
	CALL HORARIO 		;Se llama al sentido horario
	DECFSZ valorrap
	GOTO ciclorap1
	DECFSZ valorlen
	GOTO ciclolen1
	RETURN

;Girar en sentido anti-horario
EDOS:
;Se genera un ciclo anidado para llamar al sentido anti-horario varias veces
;Se da una vuelta
	MOVLW cte08
	MOVWF valorlen
ciclolen2 
	MOVLW cte40
	MOVWF valorrap
ciclorap2 
	CALL ANTIHORARIO 	;Se llama al sentido antihorario
	DECFSZ valorrap
	GOTO ciclorap2
	DECFSZ valorlen
	GOTO ciclolen2
	RETURN

;Dar cinco vueltas en sentido horario
ETRES:
	MOVLW 0X05
	MOVWF CONT 		;CONT = 5
LOOP3:
	CALL EUNO		;Dar una vuelta en sentido horario
	DECF CONT		;CONT -= 1
	CLRW
	XORWF CONT,W
	BTFSS STATUS,Z	;CONT == 0?
	GOTO LOOP3		;if false: dar otra vuelta
	GOTO LOOP 		;if true: checar entrada de nuevo
	
;Dar diez vueltas en sentido anti-horario
ECUATRO:
	MOVLW 0X0A
	MOVWF CONT		;CONT = 10
LOOP4:
	CALL EDOS		;Dar una vuelta en sentido anti-horario
	DECF CONT		;CONT -= 1
	CLRW
	XORWF CONT,W
	BTFSS STATUS,Z	;CONT == 0?
	GOTO LOOP4		;if false: dar otra vuelta
	GOTO LOOP 		;if true:  checar entrada de nuevo

;Subrutina para el sentido horario
HORARIO
	MOVLW 0XC0
	MOVWF PORTB ; PORTB = 1100 0000
	CALL RETARDO; Se llama el retardo
	MOVLW 0X60 	
	MOVWF PORTB ; PORTB = 0110 0000
	CALL RETARDO; Se llama el retardo
	MOVLW 0X30 
	MOVWF PORTB ; PORTB = 0011 0000
	CALL RETARDO; Se llama el retardo
	MOVLW 0X90
	MOVWF PORTB ; PORTB = 1001 0000
	CALL RETARDO; Se llama el retardo
	RETURN

;Subrutina para el sentido antihorario
ANTIHORARIO
	MOVLW 0XC0
	MOVWF PORTB ; PORTB = 1100 0000
	CALL RETARDO; Se llama el retardo
	MOVLW 0X90
	MOVWF PORTB ; PORTB = 1001 0000
	CALL RETARDO; Se llama el retardo
	MOVLW 0X30
	MOVWF PORTB ; PORTB = 0011 0000
	CALL RETARDO; Se llama el retardo
	MOVLW 0X60
	MOVWF PORTB ; PORTB = 0110 0000
	CALL RETARDO; Se llama el retardo	
	RETURN

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