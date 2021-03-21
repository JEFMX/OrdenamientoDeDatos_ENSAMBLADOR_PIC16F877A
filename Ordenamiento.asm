PROCESSOR 16F877
INCLUDE <P16F877.inc>

DIRO EQU H'30' ; Registro DIRO en 0x30
DIRD EQU H'31' ; Registro DIRD en 0x31
VALO EQU H'32' ; Registro VALO en 0x32
VALD EQU H'33' ; Registro VALD en 0x33

ORG 0 			;Vector reset
GOTO INICIO 	;Salta a INICIO
ORG 5 			;Se empieza a ensamblar en la direccion 0x05

INICIO:
	MOVLW H'20' ;W <-- 0x20
	MOVWF DIRO 	; DIRO <-- (W)
LOOP_1:
	MOVF DIRO,0 	; W <-- (DIRO)
	MOVWF FSR 		; FSR <-- (W)
	MOVF INDF,0 	; El valor que apunta FSR a W 
	MOVWF VALO 		; Mueve el valor de W a VALO
	GOTO ACTUALIZAR ; Salta a ACTUALIZAR
LOOP_2:
	MOVF VALD,0     ; W <-- (VALD)
	SUBWF INDF,0    ; INDF - W es decir SIG - ACTUAL
	;Se comprueba la bandera Z, si son iguales Z=1, si no Z=0
	BTFSC STATUS,Z  ; Prueba el bit Z de STATUS si Z=0 (SALTA)
	GOTO VERIFICAR  ; Si son iguales
	;Si no son iguales, se comprueba la bandera C
 	BTFSC STATUS, C ; Prueba el bit C de STATUS si C=0 (SALTA) 
	;SI C=0 entobces ACTUAL es menor
	GOTO VERIFICAR ; Salta a VERIFICAR
	;Si C=1 entonces SIG es el menor
	GOTO ACTUALIZAR ;Salata a ACTUALIZAR
ACTUALIZAR:
	MOVF INDF, 0   ;Mueve el valor al que apunta FRSR a W
	MOVWF VALD 	   ;VALD <-- (W)
	MOVF FSR, 0    ;W<--(FSR)
	MOVWF DIRD 	   ;DIRD <-- (W)
	GOTO VERIFICAR ;Salta a VERIFICAR
VERIFICAR:
	INCF FSR, 1		;Se desplaza al siguiente registro en memoria 
	BTFSS FSR,4  	;¿FSR.4 = 1?
	GOTO LOOP_2 ; Salta a LOOP_2
	GOTO CAMBIO ; Salta a CAMBIO
CAMBIO:
	MOVF DIRD,0  ;W <-- (DIRD)
	MOVWF FSR    ;FSR <-- (W)
	MOVF VALO,0  ;W<-- (VALO)
	MOVWF INDF   ;Mueve el valor al que apunta FRSR a W
	MOVF DIRO,0  ;W <--(DIRO)
	MOVWF FSR  	 ;FRS<--(W)
	MOVF VALD,0  ;W <-- (VALD)
	MOVWF INDF   ;Mueve el valor al que apunta FRSR a W
	MOVLW H'2E'  ;W <--2E
	SUBWF DIRO,0 ;Resta DIR0-W = SIG-ACTUAL
	;Se comprueba la bandera Z, si son iguales Z=1
	BTFSC STATUS, Z ; ¿Z=0?
	GOTO FINAL   ;Salta a FINAL
	INCF DIRO,1  ; DIRO<-- DIRO + 1
	GOTO LOOP_1  ;Salta a LOOP_1
FINAL:
	MOVLW H'00' ;Carga W con la litera DIR0
	MOVWF DIRO	;DIRO <--(W)
	MOVWF DIRD  ;DIRD <--(W)
	MOVWF VALO  ;VALO <-- (W)
	MOVWF VALD  ;VALD <-- (W)
	GOTO $ ;Se queda ejeutandose siempre esta instrucción
	END ; Termina el programa 