PROCESSOR P16f877
INCLUDE <p16f877.inc>

M equ H'20' 		;localidad donde se vera el resultado

		ORG 0
		GOTO INICIO

		ORG 5
INICIO: CLRW 			;inicio del programa: se limpia el valor de W
		MOVLW 01		;se coloca 01 en W
		MOVWF M 		;se mueve el valor de W a M
ROTA:	BTFSS M,7 		;se revisa el valor del bit 7 de M, si es 1 hay un salto
		GOTO SIGUE 		;si el bit 7 de M es 0, salta a la etiqueta sigue
		GOTO INICIO		;si el bit 7 de M es 1, salta al inicio del programa
SIGUE:	RLF M 			;rotan los bits en M hacia la izquierda usando el carry
		GOTO ROTA 		;salta a la etiqueta rota
		END
