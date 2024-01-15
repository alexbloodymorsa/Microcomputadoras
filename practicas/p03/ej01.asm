processor p16f877
include <p16f877.inc>

valor1 equ h'21'		;Valor 1 para el retardo
valor2 equ h'22'		;Valor 2 para el retardo
valor3 equ h'23'		;Valor 3 para el retardo
cte1 equ 80h			;constante 1 de lo que se tarda el retardo
cte2 equ 50h			;constante 2 de lo que se tarda el retardo
cte3 equ 60h			;constante 3 de lo que se tarda el retardo
 
	ORG 0
	GOTO INICIO
 	ORG 5
INICIO:
	BSF STATUS,RP0
 	BCF STATUS,RP1		;Se selecciona el banco 01
 	MOVLW H'0'
 	MOVWF TRISB			;portb = salida
 	BCF STATUS,RP0		;Se selecciona el banco 00
 	CLRF PORTB			;El valor de portb es cero
loop2:
	MOVLW 0XFF			
	MOVWF PORTB			;portb = FF = 11111111
 	CALL retardo		;Se prenden los LEDs y se llama al retardo
	CLRF PORTB			;Se apagana los LEDs
 	CALL retardo		;Se llama al retardo
 	GOTO loop2			;Se repite el ciclo
retardo:				;Se inicia el proceso de retardo
	MOVLW cte1			
 	MOVWF valor1		;valor1 = cte1
tres:
	MOVLW cte2
	MOVWF valor2		;valor2 = cte2
dos: 
	MOVLW cte3
	MOVWF valor3		;valor3 = cte3
uno:
	DECFSZ valor3		;Decrementa valor3 hasta que sea 0
 	GOTO uno
	DECFSZ valor2		;Decrementa valor2 hasta que sea 0
	GOTO dos
	DECFSZ valor1		;Decrementa valor1 hasta que sea 0
	GOTO tres
	RETURN				;Se acaba el retardo
	END