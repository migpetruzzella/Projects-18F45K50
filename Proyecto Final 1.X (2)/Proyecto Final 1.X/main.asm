; MIGUEL PETRUZZELLA
; C.I. 26.546.645
;  LA MULTIPLICACION AUN NO FUNCIONA POR FAVOR NO USAR
    
#include p18f45k50.inc  

UDATA_ACS 
    
    tabram					res 9
    
    controlador_de_lectura			res 1
    contador_de_posicion_de_dato		res 1

    aux						res 1
    aux_de_verificacion				res 1
    
    aux_numero					res 1
    var3					res 1	
    
   
    operador					res 1
   
    aux_sig0					res 1
    aux_sig1					res 1

    aux_add0					res 1
    aux_add1					res 1
					
    cont_sum0					res 1
    cont_sum1					res 1
    cont_sum2					res 1
    cont_guar					res 1
    aux_llenado	    				res 1
    aux_multiplo				res 1
    aux_multiplo0				res 1
    
    con_de_carry				res 1
    carry					res 1

    aux_comp0		    res 1
    aux_comp1		    res 1
    
    ind_comp0		    res 1
    ind_comp1		    res 1
		    
    minuendo		    res 1
    sustraendo		    res 1
    aux_de_casos	    res 1

    aux_dec		    res 1
    result		    res 1
    post_res		     res 1
		
	
    mult0		    res 1
    mult1		    res 1
    multiplo		   res 1
    multiplo0	res 1
    resmul		    res 1
    control_llenado_mul	    res 1
    
    contador  res 1
  
  
    DELAY1	res 1
    DELAY2	res  1
    DELAY3	res 1
    DELAY4	res  1


    tabresult					res 7
					
    _TRISA					 EQU	    b'00000000'		; puerto A como salieda completo
    _TRISB					 EQU	    b'00000001'		; Puerto RB0 como entrada

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

; TODO ADD INTERRUPTS HERE IF USED

MAIN_PROG CODE                      ; let linker place main program

;*****************************************************************************************
; CONFIGURACION DE LOS PUERTOS  RA0 Y RA1 SALIDA
; RB0 ENTRADA 
 
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

;***************************************************************************************
; SE ESPERA EN RB0 UN NIVEL LOGICO 0 (SE SIMULA EN STIMULUS); CUANDO LLEGA A NIVEL 0 INICIA EL PROGRAMA
INICIAL
    
    BANKSEL	PORTB 
    BTFSC	PORTB,0
    CALL	INICIAL
    GOTO	LECTURA

 ;**********************************************************************************

LECTURA
 
 
    movlw	high entrada		     ;  cargo TBLPTR con la parte alta y baja de la direccion donde estan el primer byte de la tabla
    movwf	TBLPTRH
    movlw	low entrada
    movwf	TBLPTRL
    BANKSEL	contador_de_posicion_de_dato
    CLRF	contador_de_posicion_de_dato,1	    ; EL CONTADOR DE POSICION CONTROLA LA POSICION DE DE LOS DIGITOS DE LA TABLA, VA DE 0 A 8 (LECTURA DE 9 DIGITOS)
    BANKSEL	controlador_de_lectura
    movlw	.9
    movwf	controlador_de_lectura,1	    ;cargo el controlador para leer unicamente 9 bites, este contador cuenta el numero de iteracciones
    
loop 
    
    tblrd*+					    ;  Aumento en 1 el TBLPTR y el valor del registro anteror al aumento se lo paso a TABLAT
    movf	TABLAT,w
  
    movwf	aux,1				    ; el valor que tiene TABLAT se lo cargo una variable auxiliar
    call	VERIFICAR   ;			    ; se procede a verificar si el formato es el correcto
    call	guardar				    ; se procede a guardar dicho valor en memoria ram  (una vez verificado)
    BANKSEL	contador_de_posicion_de_dato
    INCF	contador_de_posicion_de_dato,1,1    ;aumento la posicion 
    BANKSEL	controlador_de_lectura
    DECFSZ	controlador_de_lectura,1,1	    ;disminuyo el controlador de lectura y pregunto si le leyeron los 10bytes
    goto	loop
    
    goto	LECTURA_DE_OP
   
    
	
entrada CODE 
entrada DATA 0x372b, 0x3234, 0x2b2d, 0x3839, 0x35;

;**********************************VERIFICACION  
VERIFICAR
    
    BANKSEL	contador_de_posicion_de_dato
    MOVF	contador_de_posicion_de_dato,w
    MOVWF	aux_de_verificacion		    ; se carga lo leido a el auxiliar de verificacion para que este se compare con los numeros del 0 al 9
						    ; cuando el resultado de esta comparacion es 0 se procede averificar si lo leido esta acorde con el tipo de dato y formato que deberia ser
						    ; las posibilidades son simbolo (+,-), numero ( del 0x30 al ax39), simbolo plus(+,-,*)
    MOVLW	.0
    SUBWF	aux_de_verificacion,0
    BANKSEL	STATUS
    BTFSC	STATUS,2
    CALL	V_SIMBOLO
    
    MOVLW	.1
    SUBWF	aux_de_verificacion,0
    BANKSEL	STATUS
    BTFSC	STATUS,2
    CALL	V_NUMERO
    
  	
    MOVLW	.2
    SUBWF	aux_de_verificacion,0
    BANKSEL	STATUS
    BTFSC	STATUS,2
    CALL	V_NUMERO
    	
    MOVLW	.3
    SUBWF	aux_de_verificacion,0
    BANKSEL	STATUS
    BTFSC	STATUS,2
    CALL	V_NUMERO
    
    MOVLW	.4
    SUBWF	aux_de_verificacion,0
    BANKSEL	STATUS
    BTFSC	STATUS,2
    CALL	V_SIMBOLO_PLUS
    
    MOVLW	.5
    SUBWF	aux_de_verificacion,0
    BANKSEL	STATUS
    BTFSC	STATUS,2
    CALL	V_SIMBOLO
    
    MOVLW	.6
    SUBWF	aux_de_verificacion,0
    BANKSEL	STATUS
    BTFSC	STATUS,2
    CALL	V_NUMERO
    
    MOVLW	.7
    SUBWF	aux_de_verificacion,0
    BANKSEL	STATUS
    BTFSC	STATUS,2
    CALL	V_NUMERO
    
    MOVLW	.8
    SUBWF	aux_de_verificacion,0
    BANKSEL	STATUS
    BTFSC	STATUS,2
    CALL	V_NUMERO
    
RETURN 
    
V_SIMBOLO		; aqui esta verificando que es un simbolo (0x2b o 0x2d) si no es igual a alguno de estos salta a falso, si no retorna 
    
    MOVLW	    0x2b  
    SUBWF	    aux,0
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    RETURN  
   
    MOVLW	    0x2d	
    SUBWF	    aux,0
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    RETURN 
    
    GOTO	    FALSO

RETURN	       
	
    
V_SIMBOLO_PLUS		; aqui esta verificando que es un simbolo (0x2b, 0x2d o 0x2a) si no es igual a alguno de estos salta a falso, si no retorna 
    
    MOVLW	    0x2b  
    SUBWF	    aux,0
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    RETURN
   
    MOVLW	    0x2d	
    SUBWF	    aux,0
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    RETURN

	    
    MOVLW	    0x2a	
    SUBWF	    aux,0
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    RETURN
    GOTO	    FALSO 
RETURN 	
    
V_NUMERO	    ; aqui esta verificando que es un numero (el aux de numero se va aumentado de 0x30 a  0x31) si no es igual a alguno de estos salta a falso, si no retorna
    
    MOVLW	    0x30  
    BANKSEL	    aux_numero
    MOVWF	    aux_numero
    
LAZO MOVF            aux_numero,w
    SUBWF	    aux,0
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    RETURN
	    
    MOVLW	    0x39
    SUBWF	    aux_numero,0
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    GOTO	    FALSO
    INCF	    aux_numero    
    GOTO            LAZO

;******************************* HASTA AQUI ES LA VERIFICACION

;*****************************PROCESO DE GUARDADO EN MEMORIA RAM
guardar 
    
    BTFSS	var3,0          ; se le pregunta a la variable3 si esta en cero, si es asi, se carga el FSR0 con la direccion de memoria de TABRAM 
    call	carga_de_FSR0
    movf	aux,0     ; se carga POSTINCO con el valor leido de la tabla, asu ves POSTINCO almacena en memoria ram este valor, la direccion apuntada es la del FSR0, ademas aumenta el valor de FRS0 en 1
    BANKSEL	POSTINC0
    movwf	POSTINC0,1
    return 

carga_de_FSR0   ; se carga por primera vez FSR0 con la direccion de memoria de TABRAM
    
    lfsr	FSR0,tabram
    INCF	var3,1    ;se incrementa VAR3 para no volver a cargar FSR0 
    return

;***************************** TERMINA PROCESO DE GUARDADO EN MEMORIA RAM
    
 
;******************************* SALIDAS DEL SISTEMA
FALSO 
   
    bsf	    PORTA, 0
    call    RETARDO
    bcf	    PORTA, 0
    call    RETARDO
    goto    FALSO
    
VERDADERO
   
    bsf	    PORTB, 0
    call    RETARDO0
    bcf	    PORTB, 0
    call    RETARDO0
    goto    VERDADERO
 
;******************************* SALIDAS DEL SISTEMA

;******************************SE LEE EL TIPO DE OPERACION***************************************  
LECTURA_DE_OP
    
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram y se le suma 4
				    ; este valor sera el operador, dependiendo de su valor se saltara a la subrutina de suma, resta o multiplicacion
    MOVLW	    .4
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    
    BANKSEL	    INDF0	
    movf	    INDF0,w
    BANKSEL	    operador 
    movwf	    operador
    
    MOVLW	    0x2b  
    SUBWF	    operador,0
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    goto	    SUMA
   
    MOVLW	    0x2d	
    SUBWF	    operador,0
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    GOTO	    RESTA

	    
    MOVLW	    0x2a	
    SUBWF	    operador,0
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    GOTO	    MULTIPLICACION
    GOTO	    FALSO 
;******************************FINALIZADO LA LECTURA DEL TIPO DE OPERACION***************************************    

    
 ;***********************SUMA********************************************************************************    
SUMA 
    CALL	    SIGNO
s0
    CALL	    ADICION
S1
    call            LLENADO
    GOTO	    VERDADERO
    
    
;*************** SE PREGUNTA SI LOS SIGNOS DE CADA SUMANDO SON IGUALES********   

SIGNO 
    lfsr	    FSR0,tabram	     ; SE CARGAN LOS SIGNOS DE LOS SUMANDOS EN aux_sig0 y aux_sig1
    BANKSEL	    INDF0	
    movf	    INDF0,w	     
    MOVWF	    aux_sig0
    
    MOVLW	    .5
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    
    BANKSEL	    INDF0	
    movf	    INDF0,w	     
    MOVWF	    aux_sig1
    
    MOVF	    aux_sig0,W
    SUBWF	    aux_sig1,0
    
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    CALL	    SIG_IG
    
    movlw	    .7		   ;SI LLEGAMOS AQUI ES QUE LOS SIGNOS NO SON IGUALES Y SE PROCEDEA A INICIALIZAR LAS VARIABLES DE CONTROL DE LA RESTA
    movwf	    post_res
    MOVLW	    .8
    MOVWF           cont_sum0
    MOVLW	    .3
    MOVWF           cont_sum1
    MOVLW	    .4
    MOVWF           cont_sum2
    
    GOTO	    X4
    
    RETURN 

SIG_IG	    ; UNA VEZ QUE LOS SIGNOS SEAN IGUALES SE PROCEDE A GUARDAR EN LA PRIMERA POSICION DE LA TABLA DE RESULTADO EL SIGNO DEL PRIMER SIMANDO
    
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
    BANKSEL	    INDF0	
    movf	    INDF0,w	     
    MOVWF	    aux_sig0
    
    lfsr	    FSR0,tabresult     
    BANKSEL	    INDF0	
    MOVF	    aux_sig0,W
    MOVWF	    INDF0	     
    goto	    s0	    

;******************************** SE PROCEDE A SUMAR LAS UNIDADES, DECENAS Y CENTENAS, CONTADO SU RESPECTIVO CARRY. SE PROCEDE A DESARROLLAR EL ALGORITMO MAS FUMADO DE LA HISTORIA EN DONDE SE SUMAN LOS VALORES ASCII
ADICION  
    
    banksel	    cont_sum0
    MOVLW	    .8
    MOVWF           cont_sum0      ; SE CARGA LA POSICION DEL PRIMER SUMANDO
    MOVLW	    .3
    MOVWF           cont_sum1	    ; SE CARGA LA POSOCION DEL SEGUNDO SUMANDO
    MOVLW	    .3
    MOVWF           cont_sum2	    ;ESTE VA A CONTAR LA CANTIDAD DE SUMAS
    MOVLW	    .7
    MOVWF           cont_guar	    ;ESTE VA A CONTAR LA POSICION EN DONDE SE GUARDARA EN EL RESULTADO 
    
X				    ;LECTURA DE LOS SUMANDOS EN aux_add0 y aux_add1
    lfsr	    FSR0,tabram	
    
    MOVf	    cont_sum0,w
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    BANKSEL	    INDF0
    MOVFF	    INDF0, aux_add0
  
   
    lfsr	    FSR0,tabram	
    MOVF	    cont_sum1,w
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    BANKSEL	    INDF0
    MOVFF	    INDF0, aux_add1
    
    CALL	    suma_1	;SE PROCEDEN A SUMAR DICHOS NUMEROS
    
X1				    
    banksel	    cont_sum2
    DECF	    cont_sum0
    DECF	    cont_sum1
    DECF	    cont_guar
    DECFSZ	    cont_sum2,1
    GOTO	    X
    BTFSC	    carry,0
    CALL	    CARGA_CARRY
    GOTO	    S1
    
    
    RETURN
    
    
	
;************ SE SUMAN LOS DOS VALORES LEIDOS (SE SUMAN EN FORMATO ASCII BAJO ESTE ALGORITMO)  
; BASICAMENTE EL ALGORITMO SE BASA EN SUMAR LOS NUMEROS ASCCI (QUE EXADECIMAL) SI EL RESULTADO ES MENOR QUE NUEVE EJEMPLO(0X33 + 0X34) PUEDO TOMAR LOS 4 BITS MENOS SIGINIFIC
; LUEGO SI EL RESULTADO ES MAYOR QUE 9 O MENOR QUE 15, LE RESTO 10 AL RESULTADO (0X36 + 0X37) Y TOMO LOS 4 MENOS SIGNIFICATIVOS
; SI EL RESULTADO ES MAYOR QUE 15 (EL MAXIMO ES 18)  SE SUMA 6 
    
    
suma_1		    
    
    movf	    aux_add0,w
    addwfc	    aux_add1,1
    BTFSC	    aux_add1,4
    goto	    x2
    
    BCF		    aux_add1,7
    BCF		    aux_add1,6
    BCF		    aux_add1,5
    BCF		    aux_add1,4
    
    movlw	    .9
    SUBFWB	    aux_add1,w
    
    banksel	    STATUS
    BTFSS	    STATUS,4		; SI EL RESULTADO ES MAYOR QUE NUEVE SALTO
    GOTO	    CONV_ASC		; CONVIERTO EL NUEMRO EN ASC ES DECIR LOS 4 MAS SIGNIFICATICOS EN "0011'
    
    movlw	    .15
    SUBFWB	    aux_add1,w
    banksel	    STATUS
    BTFSS	    STATUS,4		; SI EL RESULTADO ES MAYOR QUE 15 SALTO Y AUMENTO EL CARRY
    call	    RES_DIEZ
    BTFSS	    STATUS,4
    call	    CONTROLDECARRY
    BTFSS	    STATUS,4
    GOTO	    CONV_ASC		; CONVIERTO EL NUEMRO EN ASC ES DECIR LOS 4 MAS SIGNIFICATICOS EN "0011'

x2  
    
    BCF		    aux_add1,7		 ; SI EL RESULTADO ES MAYOR QUE 15  LO QUE COVIERTO PRIMERO EN DECIMAL Y LE SUMO 6
    BCF		    aux_add1,6
    BCF		    aux_add1,5
    BCF		    aux_add1,4
    call	    SUMA6
    call	    CONTROLDECARRY	;	AUMENTO EL CARRY 
    GOTO	    CONV_ASC		; CONVIERTO EN ASCII
    	    
    GOTO	    $

SUMA6
    movlw	    .6
    addWF	    aux_add1,1
    return
     
     
RES_DIEZ
    
    movlw	    .10
    SUBWF	    aux_add1,1
    return
;******************* AQUI SE CONTROLA EL CARRY ******************************
; SE ACTIVA EL CONTROLADOR DE CARRY ES DECIR SE LE SUMA UN 1 A LA PROXIMA SUMATORIA Y LUEGO SE APAGA
CONTROLDECARRY
    
    banksel	    con_de_carry
    movlw	    .1
    movwf	    con_de_carry,1
    return 
aumentocarry  
    
    banksel	    carry
    movlw	    .1
    movwf	    carry,1
    CALL	    APAGADO_CONTROLDECARRY
    GOTO	    X1

APAGADO_CONTROLDECARRY
    
    banksel	    con_de_carry
    movlw	    .1
    subwf	    con_de_carry,1
    return

    
;**************************** AQUI SE CONVIERTE EL NUMERO EN ASCII
;SE OBSERVA COMO NO TIENE MUCHO SENTIDO EN HACER LA SUMA EN ASCI, LUEGO CAMBIAR A DECIMAL Y LUEGO DE NUEVO A ASCII, PERO FUE LO QUE SE ME OCURRIO EN EL MOMENTO
CONV_ASC
    
    BCF		    aux_add1,7
    BCF		    aux_add1,6
    BSF		    aux_add1,5
    BSF		    aux_add1,4   
    GOTO	    CARGA 

; YA AQUI SE CARGA EL RESULTADO EN MEMORIA
CARGA
    
    lfsr	    FSR0,tabresult	
    movf	    cont_guar,w  
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
   
    banksel	    aux_add1
    movf	    carry,w 
    addwf	    aux_add1
    clrf	    carry,1
    
    movf	    aux_add1,w
    BANKSEL	    INDF0
    MOVWF	    INDF0,1
    
    BTFSS	    con_de_carry,0
    GOTO	    X1
    GOTO	    aumentocarry
    
CARGA_CARRY
    
    lfsr	    FSR0,tabresult	
    movlw	    .4  
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    
    movlw	    0x31
    BANKSEL	    INDF0
    ADDWF	    INDF0,1
    BANKSEL         aux_llenado	 
    MOVLW	    .1
    MOVWF	    aux_llenado 
    RETURN 

; SE TERMINA DE LLENAR CON 0 LAS POSICIONES DE MEMORIA
LLENADO 
    BANKSEL         aux_llenado	 
    BTFSC	    aux_llenado,0
    movlw	    .3
    BTFSS	    aux_llenado,0
    movlw	    .4
    movwf	    aux_llenado
    
X3 
    movf	    aux_llenado,w
    lfsr	    FSR0,tabresult	
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    movlw	    0x30
    BANKSEL	    INDF0
    ADDWF	    INDF0,1
    DECFSZ	    aux_llenado
    GOTO	    X3
    RETURN 
 
;********************************************************************************************************************

RESTA

    movlw	    .7
    movwf	    post_res
    MOVLW	    .8
    MOVWF           cont_sum0
    MOVLW	    .3
    MOVWF           cont_sum1
    MOVLW	    .4
    MOVWF           cont_sum2
    CALL	    SIGNO_RES    
X5  
    DCFSNZ	    cont_sum2
    CALL	    LLENADOF
    CALL	    SUB
    GOTO $
    
; SE VERIFICA SI LOS SIGNOS SON IGUALES SI SON DIFERENTES SE ENVIA A SUMA
SIGNO_RES
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
    BANKSEL	    INDF0	
    movf	    INDF0,w	     
    MOVWF	    aux_sig0
    
    MOVLW	    .5
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    
    BANKSEL	    INDF0	
    movf	    INDF0,w	     
    MOVWF	    aux_sig1
    
    MOVF	    aux_sig0,W
    SUBWF	    aux_sig1,0
    
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    CALL	    SIG_IG_RES
    GOTO	    SIG_IG
    
    RETURN 
 
 ;SI SON IGUALES SE CARGA EL SIGNO DEL NUMERO MAYOR
SIG_IG_RES
    
    BANKSEL	    ind_comp0
    MOVLW	    .1
    MOVWF	    ind_comp0
    MOVLW	    .6
    MOVWF	    ind_comp1
    
X4
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
    BANKSEL	    ind_comp0
    MOVF	    ind_comp0,W
    BANKSEL	    FSR0L	
    ADDWF	    FSR0L,1
    BANKSEL	    INDF0
    movf	    INDF0,w	     
    MOVWF	    aux_comp0
    CALL	    CONVER_DEC
    
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
    
    BANKSEL	    ind_comp1
    MOVF	    ind_comp1,W
    BANKSEL	    FSR0L	
    ADDWF	    FSR0L,1
    BANKSEL	    INDF0
    movf	    INDF0,w	     
    MOVWF	    aux_comp1
    CALL	    CONVER_DEC
    
    BANKSEL	    ind_comp1
    MOVLW	    .1
    ADDWF	    ind_comp0
    MOVLW	    .6
    ADDWF	    ind_comp1
    
    CALL	    COMPARACION
 
    NOP
    RETURN 	    

CONVER_DEC
    
    BCF		   aux_comp0,7
    BCF		   aux_comp0,6 
    BCF		   aux_comp0,5 
    BCF		   aux_comp0,4 
   
    BCF		   aux_comp1,7 
    BCF		   aux_comp1,6 
    BCF		   aux_comp1,5 
    BCF		   aux_comp1,4 
    
    RETURN
    
COMPARACION	    ; SE COMPARA QUE NUMERO ES MAYOR Y SE CARGA EL SIGNO Y SE PROCEDE AL ALGORITMO DE RESTA
    
    BANKSEL	    aux_comp0
    MOVF	    aux_comp0,w
    SUBWF	    aux_comp1,0
    BTFSC	    STATUS,2
    goto	    X4
    MOVF	    aux_comp0,w  
    CPFSGT	    aux_comp1	    
    goto	    SIMBOL0		    ;f<w  0<1
    
    movlw	    0x2b
    subwf	    aux_sig0,0
    
    banksel	    STATUS  
    BTFSC	    STATUS,2
    goto	    SIMBOL1L		    ;f>w 
    goto	    SIMBOL1M		    ;f>w 
    
SIMBOL0
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
    BANKSEL	    INDF0	
    movf	    INDF0,w	     
    MOVWF	    aux_sig0
    
    lfsr	    FSR0,tabresult     
    BANKSEL	    INDF0	
    MOVF	    aux_sig0,W
    MOVWF	    INDF0	     
    BANKSEL	    aux_de_casos
    CLRF	    aux_de_casos
    GOTO	    X5

SIMBOL1L
   
    lfsr	    FSR0,tabresult     
    BANKSEL	    INDF0	
    MOVLW	    0x2d
    MOVWF	    INDF0	     
    BANKSEL	    aux_de_casos
    INCF	    aux_de_casos
    
    goto    	    X5

SIMBOL1M
    lfsr	    FSR0,tabresult     
    BANKSEL	    INDF0	
    MOVLW	    0x2b
    MOVWF	    INDF0	     
    BANKSEL	    aux_de_casos
    INCF	    aux_de_casos
    goto    	    X5

    

SUB    ; SE OBSERVA LOS DOS CASOS POSIBLES PRIMER DIGITO MAYOR O SEGUNDO DIGITO MAYOR 
   BANKSEL	    aux_de_casos
   BTFSC	    aux_de_casos,0
   CALL		    CAS1
   CALL		    CAS0

CAS1
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
   BANKSEL	    cont_sum0	
    MOVF	    cont_sum0,w
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    
    BANKSEL	    INDF0
    movf	    INDF0,w	     
    MOVWF	    minuendo
    CALL	    CONVDEC
    
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
    BANKSEL	    cont_sum1	
    MOVF	    cont_sum1,w
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    
    BANKSEL	    INDF0
    movf	    INDF0,w	     
    MOVWF	    sustraendo
    CALL	    CONVDEC
  
    DECF	    cont_sum0
    DECF	    cont_sum1
    CALL	    SUSTRACCION
    
CAS0
    
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
    BANKSEL	    cont_sum1	
    MOVF	    cont_sum1,w
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    
    BANKSEL	    INDF0
    movf	    INDF0,w	     
    MOVWF	    minuendo
    CALL	    CONVDEC
    
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram	
    BANKSEL	    cont_sum0
    MOVF	    cont_sum0,w
    BANKSEL	    FSR0
    ADDWF	    FSR0L,1
    
    BANKSEL	    INDF0
    movf	    INDF0,w	     
    MOVWF	    sustraendo
    CALL	    CONVDEC
    
    DECF	    cont_sum0
    DECF	    cont_sum1
    CALL	    SUSTRACCION
    
    
CONVDEC
 
    BANKSEL	    sustraendo
    BCF		    sustraendo,7
    BCF		    sustraendo,6
    BCF		    sustraendo,5
    BCF		    sustraendo,4   
    
    BCF		    minuendo,7
    BCF		    minuendo,6
    BCF		    minuendo,5
    BCF		    minuendo,4   
    return 

SUSTRACCION    ; PROCESO DE RESTA DE DIGITOS 
    
    BANKSEL	    sustraendo
    
    BTFSC	    aux_dec,0
    CALL	    DISMINUCION_MINU
    movf	    sustraendo,w
    subwf	    minuendo,0
    movwf	    result
    
    
    BANKSEL	    STATUS
    BTFSC	    STATUS,4
    call	    modificacion 
    call	    CONV_ASC2
    call	    cargar

modificacion
    banksel	    minuendo
    movlw	    .10
    addwf	    minuendo
    movf	    sustraendo,w
    subwf	    minuendo,0
    movwf	    result
    movlw	    .1
    addwf	    aux_dec
    return
    
    
DISMINUCION_MINU
    BANKSEL	    minuendo
    DECF	    minuendo,1 
    DECF	    aux_dec,1 
    return 
    
CONV_ASC2
    
    banksel	    result
    BCF		    result,7
    BCF		    result,6
    BSF		    result,5
    BSF		    result,4 
    return 
    
cargar
    
    lfsr	    FSR0,tabresult	
    MOVF	    post_res,w
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    
    movf	    result,w
    BANKSEL	    INDF0
    MOVWF	    INDF0,1
    
    decf	    post_res,1
    
    GOTO	    X5
 
LLENADOF    
    
    BANKSEL         aux_llenado	 
    movlw	    .4
    movwf	    aux_llenado
    
X7 
    movf	    aux_llenado,w
    lfsr	    FSR0,tabresult	
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    movlw	    0x30
    BANKSEL	    INDF0
    ADDWF	    INDF0,1
    DECFSZ	    aux_llenado
    GOTO	    X7
    GOTO	    VERDADERO 
 ;**********************************************************************************************************
 
MULTIPLICACION
    banksel	aux_llenado 
    movlw	.3
    movwf	aux_llenado,1
    movlw	.1
    movwf	aux_multiplo,1
    movlw	.3
    movwf	control_llenado_mul
    
    CALL	SIGMUL
X10  
    CALL	CARGARM
    CALL	MULT
    CALL	LLENADO_EN_MEMORIA

SIGMUL 
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
    BANKSEL	    INDF0	
    movf	    INDF0,w	     
    MOVWF	    aux_sig0
    
    MOVLW	    .5
    BANKSEL	    FSR0L
    ADDWF	    FSR0L,1
    
    BANKSEL	    INDF0	
    movf	    INDF0,w	     
    MOVWF	    aux_sig1
    
    MOVF	    aux_sig0,W
    SUBWF	    aux_sig1,0
    
    BANKSEL	    STATUS
    BTFSC	    STATUS,2
    CALL	    RESPOS
    CALL	    RESNEG
    

RESPOS
    lfsr	    FSR0,tabresult     
    BANKSEL	    INDF0	
    MOVLW	    0x2b
    MOVWF	    INDF0	     
    GOTO	    X10
    
RESNEG
    lfsr	    FSR0,tabresult     
    BANKSEL	    INDF0	
    MOVLW	    0x2d
    MOVWF	    INDF0	     
    GOTO	    X10
    
CARGARM
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
    BANKSEL	    aux_llenado
    MOVF	    aux_llenado,w
    
    BANKSEL	    FSR0L	
    ADDWF	    FSR0L,1
    BANKSEL	    INDF0
    movf	    INDF0,w	     
    MOVWF	    mult0
    CALL	    CONVER_DECM
       decfsz	    control_llenado_mul,1
    CALL	    LLENADO_MULTIPLO
 
    
    lfsr	    FSR0,tabram	     ; se carga el FRS0 con la direccion del tabram
    movlw	    .8
    BANKSEL	    FSR0L	
    ADDWF	    FSR0L,1
    BANKSEL	    INDF0
    movf	    INDF0,w	     
    MOVWF	    mult1
    CALL	    CONVER_DECM
    RETURN

LLENADO_MULTIPLO
    
    BANKSEL	    multiplo 
    MOVF	    mult0,w
    MULWF	    aux_multiplo
    
    BANKSEL	    PRODL
    MOVFF	    PRODL,multiplo
    MOVF	    multiplo,w
    addwf	    multiplo0,1
   
    BANKSEL	    aux_llenado
    movlw	    .10
    mulwf	    aux_multiplo
    BANKSEL	    PRODL
    MOVFF	    PRODL,aux_multiplo
    decf	    aux_llenado
    goto	    CARGARM
  
    
    
    
CONVER_DECM
 
    BANKSEL	    mult0
    BCF		    mult0,7
    BCF		    mult0,6
    BCF		    mult0,5
    BCF		    mult0,4   
    
    BCF		    mult1,7
    BCF		    mult1,6
    BCF		    mult1,5
    BCF		    mult1,4   
    return 

MULT
    
    BANKSEL	    mult0
    movf	    mult0,w
    MULWF	    mult1
    BANKSEL	    PRODL
    MOVFF	    PRODL,resmul
   
    nop
LLENADO_EN_MEMORIA  
;*********************************************************************************************  
; LA MULTIPLICACION NO SIRVE   

RETARDO
      
RETARDO3
    MOVLW   .150
    MOVWF   DELAY2
    
RETARDO2
    MOVLW   0xff
    MOVWF   DELAY1

RETARDO1
    DECFSZ  DELAY1, 1
    BRA	    RETARDO1
    DECFSZ  DELAY2, 1
    BRA	    RETARDO2
    RETURN
;*******************************************
    
RETARDO0
      
RETARDO30
    MOVLW   .10
    MOVWF   DELAY2
    
RETARDO20
    MOVLW   .180
    MOVWF   DELAY1

RETARDO10
    DECFSZ  DELAY1, 1
    BRA	    RETARDO10
    DECFSZ  DELAY2, 1
    BRA	    RETARDO20
    RETURN
    
    
    GOTO $                          ; loop forever

    END