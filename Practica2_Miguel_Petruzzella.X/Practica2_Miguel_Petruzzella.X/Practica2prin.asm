; MIGUEL PETRUZZELLA
; C.I. 26.546.645
    
#include p18f45k50.inc  

UDATA_ACS 

	controlador_de_lectura			res 1
	var2					res 1
	var3					res 1
	var_de_trabajo				res 1
	var_de_comparacion			res 1
	contador_segundario			res 1
	contador_principal			res 1
 	
	tabram					res 10 
 
    
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

START
       
    movlw	high tabla   ;  cargo TBLPTR con la parte alta y baja de la direccion donde estan el primer byte de la tabla
    movwf	TBLPTRH
    movlw	low tabla
    movwf	TBLPTRL
    movlw	.10
    movwf	controlador_de_lectura,1 ;cargo el controlador para leer unicamente 10 bytes
    
loop 
    
    tblrd*+	;  Aumento en 1 el TBLPTR y el valor del registro anteror al aumento se lo paso a TABLAT
    movf	TABLAT,w
  
    movwf	var2,1	    ; el valor que tiene TABLAT se lo cargo una variable auxiliar
    call	guardar	    ; se procede a guardar dicho valor en memoria ram 
    BANKSEL	controlador_de_lectura
    decfsz	controlador_de_lectura,1,1  ;disminuyo el controlador de lectura y pregunto si le leyeron los 10bytes
    goto	loop
    
    movlw	.9                 ;una vez llegado aqui se cargaron todos los datos a la memoria ram procede a cargar el contador de ordenado y a ordenarlo 
    movwf	contador_principal
    goto	ordenado
    
	
tbl CODE 
tabla DATA 0x0602, 0x0405, 0x0606, 0x0504, 0xffff, 0xffff  ; mi cedula es 26.546.645
 
guardar 
    
    BTFSS	var3,0          ; se le pregunta a la variable3 si esta en cero, si es asi, se carga el FSR0 con la direccion de memoria de TABRAM 
    call	carga_de_FSR0
    movf	var2,0     ; se carga POSTINCO con el valor leido de la tabla, asu ves POSTINCO almacena en memoria ram este valor, la direccion apuntada es la del FSR0, ademas aumenta el valor de FRS0 en 1
    BANKSEL	POSTINC0
    movwf	POSTINC0,1
    return 

carga_de_FSR0   ; se carga por primera vez FSR0 con la direccion de memoria de TABRAM
    
    lfsr	FSR0,tabram
    INCF	var3,1    ;se incrementa VAR3 para no volver a cargar FSR0 
    return
    

ordenado			    ; una vez leida la tabla y almacenada en memoria RAM se procede a ordenarlos
    
    lfsr	FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
    BANKSEL	INDF0	
    movf	INDF0,W		    ; cargamos w con el valor del registro al cual apuntata FRS0L
    
    
    BANKSEL	var_de_trabajo         
    movwf	var_de_trabajo,1    ; cargo la variable de trabajo con el valor del registro de la mamoria ram al cual apunta FSR0L 
    
    BANKSEL	FSR0L  
    INCF	FSR0L,1		    ; Incremento la parte baja de FRS para apuntar al siguente registro en la memoria 
    
    movf	INDF0,W		    ; leo el valor de memoria se lo asigno a una variable a comparar
    BANKSEL	var_de_comparacion
    movwf	var_de_comparacion,1
    
    
    movlw	.9
    movwf	contador_segundario,1  ;cargo el contador segundario con el numero de comparaciones que debe hacer
    
    DCFSNZ	contador_principal,1	; le pregunto al contador principal si termino.
    goto $				; FIN DEL PROGRAMA
    
        
LAZO    
   
    movf	var_de_comparacion,w   ; comparo la variable de trabajo, con la variable de comparacion y si es menor los permuto de posicion
    CPFSGT	var_de_trabajo,1
    call	cambia_pos
    
    BANKSEL	INDF0         ;asigno el valor de la posicion siguente a la variable de trabajo
    movf	INDF0,W
    BANKSEL	var_de_trabajo
    movwf	var_de_trabajo,1 
    
    BANKSEL	FSR0L	;incremento en 1 el FSR0L y el valor del registro apuntado se lo cargo a la variable de comparacion
    INCF	FSR0L,1
    
    movf	INDF0,W
    BANKSEL	var_de_comparacion
    movwf	var_de_comparacion,1
    
    DCFSNZ	contador_segundario,1 ; le pregunto al contador segundario si ya termino iterar en la tabla, recordamos que son 10 iteraciones para segurarnos que quede bien ordenada
    
    GOTO	ordenado
    GOTO	LAZO

    
cambia_pos    ; en esat sub rutina se permuta la posicion de los valores en la tabla
    
    MOVFF	var_de_trabajo,INDF0   ;le asigno el valor de trabajo a la posicion siguente en memoria
    
    BANKSEL	FSR0L      ;decremento en FRS0L para apuntar a la posicion anterior
    DECF	FSR0L,1
    MOVFF	var_de_comparacion,INDF0   ;le asigno el valor comparacion a la posicion anterior en memoria
    INCF	FSR0L,1   ;aumento el FRS0L para apuntar a la posicion original y segur con el lazo anterior.
    
    return 
    
    
    
    goto $
    
 
    GOTO $                          ; loop forever

    END