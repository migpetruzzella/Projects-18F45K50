; Miguel Pteruzzella
; C.I. 26.546.645
; Microcontroladores 1

#include p18f45k50.inc   
    

    
    UDATA 
auxiliar res 1       ; se definen auxliares de suma y muliplicacion
auxiliarmul res 1

resultadol res 1      ; se definen variables de resultados low and high 
resultadoh res 1

resulmul res 1        ; se define variable de resultado
operacion res 1	      ; se define la operacion

#define  sum1l	b'11111111'    ; numero sumando low
#define	 sum1h  0x08		; numero sumando high
 
#define	 sum2l  b'00000001'    ; numero sumando low
#define	 sum2h  b'00000010'	; numero sumando high 

#define fact1 d'1'	    ; factor 1
#define fact2 d'2'	; factor 2
 
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program


                      ; let linker place main program

START

    BANKSEL operacion   
    movlw 0x3      ;  <------------ AQUI SE COLOCA EL TIPO DE OPERACION.
    movwf operacion,1    ; se define el tipo de operacion 
    
    movlw 0x1
    subwf operacion, 0, 1   
    BTFSC 0xFD8, 0x2  ;se revisa el bit numero 2 del registro STATUS, a ver si la opracion anterior fue cero
    goto suma
    
    movlw 0x2
    subwf operacion, 0, 1
    BTFSC 0xFD8, 0x2
    goto resta
    
    movlw 0x3
    subwf operacion, 0, 1
    BTFSC 0xFD8, 0x2
    goto multiplica

suma:  
    
    BANKSEL sum1l  
    movlw sum1l     ; se carga w con el valor low del sumando 1
    movwf auxiliar,1  ; se carga el auxuiliar con el valor low del sumando 1
    movlw sum2l       ; se carga w con el valor low del sumando 2
    addwf auxiliar,0,1  ; se suma y se guarda en resultado low 
    movwf resultadol,1
    
    movlw sum1h        ; se carga sumando 1 high al axuliar 
    movwf auxiliar,1
    movlw sum2h		; se carga sumando 2 high al auxliar
    addwfc auxiliar,0,1  ; se suman incluido el carry y se guarda en el resultado high
    movwf resultadoh,1
    goto fin
    
    
    
    
resta: 
    
    BANKSEL sum1l     ;cabe destacar que se hace una resta complementoa dos
			; basicamente se hace el mismo procedimiento del sumando, solo que se reliza la resta 
			;y la resta con borrow
    movlw sum1l
    movwf auxiliar,1
    movlw sum2l
    subwf auxiliar,0,1
    movwf resultadol,1
    
    movlw sum1h
    movwf auxiliar,1
    movlw sum2h
    subwfb auxiliar,0,1
    movwf resultadoh,1
    goto fin
    
multiplica:
    
    BANKSEL fact1  
    movlw fact1       ; se carga auxiliar con el valor del primer factor
    movwf auxiliar,1  
    movlw fact2        ; se caga el factor 2 al auxiliarmul
    movwf auxiliarmul,1   
    decf auxiliar,1     ; decrementas en 1 el auxiliar 
loop:   
    
    movlw fact2        ;  mueves lo que estaba en factor2 al acumulador y lo sumas con el auxiliarmul
    addwf auxiliarmul,1
    DECFSZ auxiliar,1    ;decrementas el auxiliar y ves si llego a cero, si es asi salta y cuarda el resultado 
    goto loop            ; si el decremento NO es cero devuelvete al loop
    movf auxiliarmul,0,1
    movwf resulmul
    goto fin
    
    
    
    
    
    
  
 fin: GOTO $                          ; loop forever

    END