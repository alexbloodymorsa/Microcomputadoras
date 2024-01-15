PROCESSOR 16F877
INCLUDE <P16F877.INC>

valor1 equ h'21'		;Variable para el retardo
valor2 equ h'22'		;Variable para el retardo
valor3 equ h'23'		;Variable para el retardo
cte1 equ 20h			;Constante para el retardo
cte2 equ 50h			;Constante para el retardo
cte3 equ 60h			;Constante para el retardo
estado0 equ 0x00		;Valor estado 0
estado1 equ 0x01		;Valor estado 1
estado2 equ 0x02		;Valor estado 2
estado3 equ 0x03		;Valor estado 3
estado4 equ 0x04		;Valor estado 4
estado5 equ 0x05		;Valor estado 5
banderarota equ h'24' 	;Bandera rotación: 0=der, 1=izq
valore2 equ h'25'		;Variable para el estado 2
valore3 equ h'26'		;Variable para el estado 3
valore4 equ h'27'		;Variable de salida estado 4
valor7 equ h'28'		;Contador para estado 4

	ORG 0			 	;Vector de reset
	GOTO INICIO
	
	ORG 5
INICIO: 
	CLRF PORTA 			;Limpia PORTA
	BSF STATUS,RP0 		;Cambia a banco 1
	BCF STATUS,RP1
	MOVLW 06H 			;Define puertos A y E como digitales
	MOVWF ADCON1
	MOVLW H'3F' 		;Configura puerto A como entrada
	MOVWF TRISA
	CLRF TRISB			;Configura puerto B como salida
	BCF STATUS,RP0 		;Cambia al banco 00 
	BCF STATUS,C		;Limpia el carry
	CLRF banderarota	;Limpia la bandera de rotación
	MOVLW 0X80
	MOVWF valore2		;valore2 = 80
	MOVWF valore4		;valore4 = 80
	MOVLW 0X01
	MOVWF valore3		;valore3 = 01
	MOVLW 0X07
	MOVWF valor7		;valor7 = 07


LOOP:					;Determinar en qué estado se está
	MOVLW estado0
	XORWF PORTA,W		;Se compara puertoA == estado0
	BTFSC STATUS,Z		;Saltar si no son iguales
	GOTO ECERO			;Ir a ECERO si son iguales
						
	MOVLW estado1
	XORWF PORTA,W		;Se compara puertoA == estado1
	BTFSC STATUS,Z		;Saltar si no son iguales
	GOTO EUNO			;Ir a EUNO si son iguales
	
	MOVLW estado2
	XORWF PORTA,W		;Se compara puertoA == estado2
	BTFSC STATUS,Z		;Saltar si no son iguales
	GOTO EDOS			;Ir a EDOS si son iguales
	
	MOVLW estado3
	XORWF PORTA,W		;Se compara puertoA == estado3
	BTFSC STATUS,Z		;Saltar si no son iguales
	GOTO ETRES			;;Ir a ETRES si son iguales
	
	MOVLW estado4		
	XORWF PORTA,W		;Se compara puertoA == estado4
	BTFSC STATUS,Z		;Saltar si no son iguales
	GOTO ECUATRO		;Ir a ECUATRO si son iguales
	
	MOVLW estado5
	XORWF PORTA,W		;Se compara puertoA == estado5
	BTFSC STATUS,Z		;Saltar si no son iguales
	GOTO ECINCO			;Ir a ECINCO si son iguales
	GOTO LOOP			;Regresar al LOOP

ECERO:					;Estado 0
	CLRF PORTB			;Se apaga la salida
	GOTO LOOP			;Se revisa la entrada 
	
EUNO:					;Estado 1
	MOVLW 0XFF			
	MOVWF PORTB			;puertoB = FF (se prende salida)
	GOTO LOOP			;Se revisa la entrada 
		
EDOS:					;Estado 2
	RRF valore2			;Rotar a la derecha valore2
	MOVF valore2,W 		
	MOVWF PORTB			;puertoB = valore2
	CALL RETARDO		;Se llama el retardo
	GOTO LOOP			;Se revisa la entrada 
	
ETRES:					;Estado 3
	RLF valore3			;Rotar a la izquierda valore3
	MOVF valore3,W		
	MOVWF PORTB			;puertoB = valore3
	CALL RETARDO		;Se llama al retardo
	GOTO LOOP			;Se revisa la entrada 
	
ECUATRO:				;Estado 4
	BTFSS banderarota,0 ;Checa el valor de la bandera de rotación
	GOTO ROTADER		;Si es cero rota a la derecha
	GOTO ROTAIZQ		;Si es uno rota a la izquierda
ROTADER:				;Rotación a la derecha
	RRF valore4			;Rota a la derecha valore4
	DECF valor7			;Decrementa el contador
	CLRW 				;Limpia W
	XORWF valor7,W		;Checar si el contador es cero
	BTFSS STATUS,Z
	GOTO FINAL			;Si no es cero se va directo a FINAL
	BSF banderarota,0	;Si es cero cambia la bandera para rotar izq
	GOTO FINAL			;Ir a FINAL
ROTAIZQ:				;Rotación a la izquierda
	RLF valore4			;Rota a la izquierda los valores de valore4
	INCF valor7			;Incrementar el contador
	MOVLW 0X07			;W = 07
	XORWF valor7,W		;Checar si el contador es 7
	BTFSS STATUS,Z
	GOTO FINAL			;Si no es 7 se va directo a FINAL
	BCF banderarota,0	;Si es 7 se cambia la bandera para rotar der
	GOTO FINAL			;Ir a FINAL
FINAL:
	MOVF valore4,W		
	MOVWF PORTB			;puertoB = valore4
	CALL RETARDO		;Llamar al retardo
	GOTO LOOP			;Se revisa la entrada 

ECINCO:					;Estado 5
	CLRW				
	MOVWF PORTB			;puertoB = 00
	CALL RETARDO		;Se llama al retardo
	MOVLW 0XFF
	MOVWF PORTB			;puertoB = FF
	CALL RETARDO		;Se llama al retardo
	GOTO LOOP			;Se revisa la entrada 
	
	
	
RETARDO					;Subrutinan retardo
	MOVLW cte1
	MOVWF valor1		;valor1 = cte1
tres 
	MOVLW cte2
	MOVWF valor2		;valor2 = cte2
dos 
	MOVLW cte3
	MOVWF valor3		;valor3 = cte3
uno 
	DECFSZ valor3		;decrementar valor 3
	GOTO uno			;ir a uno
	DECFSZ valor2		;decrementar valor 2
	GOTO dos			;ir a dos
	DECFSZ valor1		;decrementar valor 1
	GOTO tres			;ir a tres
	RETURN				;fin subrutina
	
	END