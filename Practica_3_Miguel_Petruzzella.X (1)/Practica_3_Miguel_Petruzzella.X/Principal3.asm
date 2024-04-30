; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
include p18f45k50.inc 	;Incluyo archivo de cabecera con definición de registros propios del microcontrolador

UDATA_ACS

    RETARDO1		 RES 1
    RETARDO2		 RES 1
 
    _TRISA	    EQU	    b'00000000'
    _TRISB	    EQU	    b'00000001'
	    
    LED1	    EQU 0
    LED2	    EQU 1
    LED3	    EQU 2
    LED4	    EQU 3
    
	    


	    
	    
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE  ; let linker place main program

START
 
    movlb	00h
    clrf	LATA
    
    BANKSEL	ANSELA
    clrf	ANSELA
    BANKSEL	TRISA
    movlw	_TRISA
    movwf	TRISA
    
    BANKSEL	ANSELB
    clrf	ANSELB
    BANKSEL	TRISB
    movlw	_TRISB
    movwf	TRISB

    BANKSEL	RETARDO1
    movlw	0xff
    movwf	RETARDO1,1
    
    BRA		INICIAL
    

INICIAL
    
    BANKSEL	PORTB 
    BTFSC	PORTB,0
    CALL	AUMENTO_INICIAL
    GOTO	INICIAL 
    
AUMENTO_INICIAL
    
    BANKSEL	LATA
    MOVLW	.1
    ADDWF	LATA,1
    GOTO	SUBIDA_SET 

    
    
;********************************************************************************************************************************************************************************

  
SUBIDA_SET
    
    
    CALL	AUMENTO
    BANKSEL	PORTB 
    BTFSS	PORTB,0
    BRA		SUBIDA_LOW
    GOTO	SUBIDA_SET

SUBIDA_LOW
    
   
    CALL	AUMENTO
    BANKSEL	PORTB 
    BTFSC	PORTB,0
    BRA		BAJADA_SET
    GOTO	SUBIDA_LOW

    
BAJADA_SET
    
    GOTO	RETARDO
    CALL	DECREMENTO
    BANKSEL	PORTB 
    BTFSS	PORTB,0
    BRA		BAJADA_LOW
    GOTO	BAJADA_SET
    
BAJADA_LOW
    
    CALL	DECREMENTO
    BANKSEL	PORTB 
    BTFSC	PORTB,0
    BRA		SUBIDA_SET
    GOTO	BAJADA_LOW
 
 ;***********************************************************************************   
   
 
    
AUMENTO
    
    BANKSEL	LATA
    MOVLW	.1
    ADDWF	LATA,1
    CALL	RETARDO
    RETURN      

DECREMENTO
    
    BANKSEL	LATA
    MOVLW	.1
    SUBWF	LATA,1
    CALL	RETARDO
    RETURN 
    
;*********************
    

RETARDO 
    
   
    BANKSEL	RETARDO1
    DECFSZ	RETARDO1,1
    goto	RETARDO
    CALL	RETARDO_2
    DECFSZ	RETARDO2,1
    goto	RETARDO
    goto	RETARDO
    RETURN 
    
RETARDO_2
    MOVLW	0xff
    movwf	RETARDO2,1
    RETURN 
    
    
   

    GOTO $                          ; loop forever

    END