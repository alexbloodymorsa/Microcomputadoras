PROCESSOR 16F877
INCLUDE <P16F877.INC>

valor1 equ h'21'		;Valor para el retardo
valor2 equ h'22'		;Valor para el retardo
valor3 equ h'23'		;Valor para el retardo
cte1 equ 20h			;Constante para el retardo
cte2 equ 50h			;Constante para el retardo
cte3 equ 60h			;Constante para el retardo
CONT equ h'25'			;Contador para cada estado

	ORG 0 				;Vector de reset
	GOTO INICIO
	
	ORG 5
INICIO: 
	CLRF PORTA 			;Limpia PORTA
	BSF STATUS,RP0 		;Cambia a banco 1
	BCF STATUS,RP1
	CLRF TRISB			;Configura el puerto B como salida
	BCF STATUS,RP0 		;Cambia al banco 0 
	BCF STATUS,C		;Limpia el acarreo
	
LOOP:
	MOVLW 0X0A
	MOVWF CONT			;CONT = A

EDO1:					;Prender y apagar
	CLRW				
	MOVWF PORTB			;Se apaga la salida
	CALL RETARDO		;Se llama al retardo
	MOVLW 0XFF
	MOVWF PORTB			;Se prende la salida
	CALL RETARDO		;Se llama al retardo
	DECF CONT			;Decrementar el contador
	CLRW
	XORWF CONT,W		
	BTFSS STATUS,Z		;Compara CONT == 0
	GOTO EDO1			;Si no es cero volver a EDO1

	MOVLW 0X07
	MOVWF CONT			;CONT =  07
	MOVLW 0X80			
	MOVWF PORTB			;PORTB = 80
	CALL RETARDO		;Llamar retardo

EDO2:					;Rotar a la derecha
	RRF PORTB			;Rotar a la derecha el valor del puerto
	CALL RETARDO		;Llamar al retardo
	DECF CONT			;Decrementar el contador
	CLRW				
	XORWF CONT,W		
	BTFSS STATUS,Z		;Comparar CONT == 0
	GOTO EDO2			;Si no es cero volver a EDO2

	MOVLW 0X07
	MOVWF CONT			;CONT = 07
	MOVLW 0X01
	MOVWF PORTB			;PORTB = 01
	CALL RETARDO		;Llamar al retardo

EDO3:					;Rotar a la izquierda
	RLF PORTB			;Rotar a la izquierda el valor del puerto
	CALL RETARDO		;Llamar al retardo
	DECF CONT			;Decrementar el contador
	CLRW
	XORWF CONT,W
	BTFSS STATUS,Z		;Comparar CONT == 0
	GOTO EDO3			;Si no es cero volver a EDO3

	MOVLW 0X0A
	MOVWF CONT			;CONT = A

EDO4:					;Prender uno sí, uno no y alternar
	MOVLW 0XAA
	MOVWF PORTB			;PORTB = AA
	CALL RETARDO		;Llamar retardo
	MOVLW 0X55
	MOVWF PORTB			;PORTB = 55
	CALL RETARDO		;Llamar retardo
	DECF CONT			;Decrementar el contador
	CLRW
	XORWF CONT,W
	BTFSS STATUS,Z		;Comparar CONT == 0
	GOTO EDO4			;Si no es cero volver a EDO4
	GOTO LOOP			;Volver a iniciar el LOOP

	
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