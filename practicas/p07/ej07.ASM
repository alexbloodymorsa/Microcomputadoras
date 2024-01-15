processor 16f877
include<p16f877.inc>

VOLTAJE EQU 0X22		;Valor de voltaje	

CENT EQU 0X27			;Valor centenas
DECE EQU 0X28			;Valor decenas
UNI EQU 0X29			;Valor unidades

;Valores para el retardo
valor1 equ h'24
valor2 equ h'25
valor3 equ h'26
cte1 equ 20h
cte2 equ 50h
cte3 equ 60h

	ORG 0
	GOTO inicio
	ORG 5

inicio
	BSF STATUS,RP0
	BCF STATUS,RP1			;Se cambi al banco 01
	CLRF ADCON1				;ADCON1 = 00 -> PUERTO A Y E ANALOGICOS
	BSF TRISE,0				
	BSF TRISE, 0X00
	BSF TXSTA,BRGH			;Cambia bandera BRGH
	MOVLW D'129'
	MOVWF SPBRG				;Baud rate = 9600
	BCF TXSTA,SYNC			;ComunicaciÛn sÌncrona
	BSF TXSTA,TXEN			;Activa transmisiÛn
	
	BCF STATUS,RP0			;Se cambia al banco 0
	MOVLW B'11101001'		;W = 11101001
	MOVWF ADCON0			;Configura ADCON0 con W: usara reloj interno, canal 5, DONE, conv.A/D encendido
	
	BSF RCSTA,SPEN			;Habilita puerto serie
	BSF RCSTA,CREN			;RecepciÛn sencilla

RECIBE
	BTFSS PIR1,RCIF			;Bandera de recepciÛn completa
	GOTO RECIBE				;Esperar recepciÛn
	
	CLRF CENT				;Centenas = 0
	CLRF DECE				;Decenas = 0
	CLRF UNI				;Unidades = 0
	CALL CONVIERTE 			;Convierte valor a digital
	MOVWF VOLTAJE 			;Voltaje = valor digital

	BTFSS VOLTAJE,7     ;Bit 7 = 1 salta
    GOTO V125   		 ;B7 = 0
    MOVLW 0X02   		 ;W = 2 (B7 = 1)
    ADDWF CENT   		 ;CENT + W
    MOVLW 0X05   		 ;W = 5
    ADDWF DECE   		 ;DECE + W

V125
	BTFSS VOLTAJE,6     ;Bit 6 = 1 salta
    GOTO V063   		 ;B6 = 0
    MOVLW 0X01   		 ;W = 1 (B6 = 1)
    ADDWF CENT   		 ;CENT + W
    MOVLW 0X02   		 ;W = 2
    ADDWF DECE   		 ;DECE + W
    MOVLW 0X05   		 ;W = 5
    ADDWF UNI    		 ;UNI + W

V063
    BTFSS VOLTAJE,5   	 ;Bit 5 = 1 salta
    GOTO V032   		 ;B5 = 0
    MOVLW 0X06   		 ;W = 6 (B5 = 1)
    ADDWF DECE   		 ;DECE + W
    CALL INC_CENT   	 ;Llamado a INC_CENT
    MOVLW 0X03   		 ;W = 3
    ADDWF UNI   		 ;UNI + W
    CALL INC_DECE   	 ;Llamado a INC_DECE

V032
    BTFSS VOLTAJE,4   	 ;Bit 4 = 1 salta
    GOTO V016   		 ;B4 = 0
    MOVLW 0X03   		 ;W = 3 (B4 = 1)
    ADDWF DECE   		 ;DECE + W
    CALL INC_CENT   	 ;Llamado a INC_CENT
    MOVLW 0X02   		 ;W = 2
    ADDWF UNI   		 ;UNI + W
    CALL INC_DECE   	 ;Llamado a INC_DECE

V016
    BTFSS VOLTAJE,3   	 ;Bit 3 = 1 salta
    GOTO V008   		 ;B3 = 0
    MOVLW 0X01   		 ;W = 1 (B3 = 1)
    ADDWF DECE   		 ;DECE + W
    CALL INC_CENT   	 ;Llamado a INC_CENT
    MOVLW 0X06   		 ;W = 6
    ADDWF UNI   		 ;UNI + W
    CALL INC_DECE   	 ;Llamado a INC_DECE

V008
    BTFSS VOLTAJE,2   	 ;Bit 2 = 1 salta
    GOTO V004   		 ;B2 = 0
    MOVLW 0X08   		 ;W = 8 (B2 = 1)
    ADDWF UNI   		 ;UNI + W
    CALL INC_DECE   	 ;Llamado a INC_DECE

V004
    BTFSS VOLTAJE,1   	 ;Bit 1 = 1 salta
    GOTO V002   		 ;B1 = 0
    MOVLW 0X04   		 ;W = 4 (B1 = 1)
    ADDWF UNI   		 ;UNI + W
    CALL INC_DECE   	 ;Llamado a INC_DECE

V002
    BTFSS VOLTAJE,0   	 ;Bit 0 = 1 salta
    GOTO ASCII		   	 ;B0 = 0
    MOVLW 0X02   		 ;W = 2 (B0 = 1)
    ADDWF UNI   		 ;UNI + W
    CALL INC_DECE   	 ;Llamado a INC_DECE

;Transmitiendo el valor ASCII
ASCII
	MOVLW 0X30			;Sumar 30 para valor ASCII a:
	ADDWF CENT			;centenas
	ADDWF DECE			;decenas
	ADDWF UNI 			;unidades
	
	MOVF CENT,W			
	CALL TRANSMITE		;Transmitir centenas
	MOVF DECE,W
	CALL TRANSMITE		;Transmitir decenas
	MOVLW 0X2E
	CALL TRANSMITE		;Transmitir un punto
	MOVF UNI,W
	CALL TRANSMITE		;Transmitir unidades
	MOVLW a' '
	CALL TRANSMITE		;Transmitir espacio
	MOVLW 0XA7
	CALL TRANSMITE		;Transmitir grados
	MOVLW a'C'
	CALL TRANSMITE		;Transmitir C
	MOVLW 0X0D
	CALL TRANSMITE		
	MOVLW 0X0A
	CALL TRANSMITE		;Transmite el fin de la cadena
	GOTO RECIBE			;Recibe otro dato
	

TRANSMITE:
	MOVWF TXREG			;TransmisiÛn = W
TRA
	BSF STATUS,RP0		;Cambiar al banco 01
ESP	
	BTFSS TXSTA,TRMT	;Bandera de transmisiÛn completa
	GOTO ESP			;Esperar transmisiÛn
	CALL RETARDO		;Se llama el retardo
	BCF STATUS,RP0		;Cambiar al banco 00
	RETURN


CONVIERTE
	BSF ADCON0,2  			;prende bit 2 de ADCON0 -> GO: inicia la comparaci√≥n
	CALL RETARDO			;llama subrutina de retardo
ESPERA
	BTFSC ADCON0,2 			;checa bit 2 de ADCON0
	GOTO ESPERA				;Si es 1, regresa a la etiqueta ESPERA
	MOVF ADRESH,W 			;Si es 0, W = ADRESH
	RETURN

INC_CENT  
    MOVLW 0X0A				;W=0A
    SUBWF DECE,W	        ;W = DECE-0A
    BTFSS STATUS, C			;salta si C = 1
    RETURN					;return si C=0
    INCF CENT				;CENT = CENT + 1 (C=1)
    MOVWF DECE				;DECE = W
    RETURN

INC_DECE
    MOVLW 0X0A				;W=0A	
    SUBWF UNI,W				;W = UNI-0A
    BTFSS STATUS, C			;salta si C = 1
    RETURN					;return si C=0
    INCF DECE				;DECE = DECE + 1 (C=1)
    MOVWF UNI				;UNI = W
    CALL INC_CENT 			;llama INC_CENT
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