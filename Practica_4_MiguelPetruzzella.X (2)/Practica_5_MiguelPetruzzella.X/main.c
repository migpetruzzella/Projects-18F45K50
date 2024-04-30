
#include <xc.h>
#include <string.h>
#include <stdio.h>
#include "config.h"
#include <ctype.h>

#define _XTAL_FREQ 48000000    //defino frecuencia del oscilador para que el macro delay defina el retardo/*


__attribute__((address(0x1006))) const int firma[] = {0x600d}; //incluyo firma para que el bootloadre reconazca el programa de usuario
void tx_232(char *,char *,char *,char *,char *); //prototipo de la funcion tx_232
void tx_232e(char *); //prototipo de la funcion tx_232 para el caso de error


char numeros[4],contador=0;        // Numero de caracteres que se ingresaran y contador 
int unid, dece, cente;      // declaro  unidad, decena y centena como numeros enters



void __interrupt(low_priority) lint(void)
{
    char    valor_recibido;
        if(PIR1bits.RCIF){// verifico interrupcion por recepcion de puerto serial                    
            valor_recibido=RCREG1;      //leo el byte recibido
            if(RCSTA1bits.OERR){ //verifio si hay error de overun y borro bandera de error
                RCSTAbits.CREN=0;
                RCSTAbits.CREN=1;
            }
        if (contador < 4) {
            numeros[contador] = valor_recibido;
            contador++;
        }
            }
    return;        
}

void main(void) {

    config();
    while(1){
        
        if (contador == 4) {
            
            int i;

            for (i = 0; i < 4; i++) {
            if (!isdigit(numeros[i])) {
            break;
            }
            }
            
            if (i == 4) {
    

            int numero1 = 0;
            int k;

            for (k = 0; k< 2; k++) {
            numero1 = numero1 * 10 + (numeros[i] - '0');
            }
            int numero2 = 0;

            for (k = 2; k < 4; i++) {
            numero2 = numero2 * 10 + (numeros[i] - '0');
}

                int suma = numero1 + numero2;          

                unid = suma % 10;         
                dece = (suma / 10) % 10;
                cente = suma / 100;
         
                char unidsal[2], decesal[2], centesal[2];              
               

                sprintf(unidsal,"%d",unid);     
                sprintf(decesal,"%d",dece);
                sprintf(centesal,"%d",cente);

                tx_232("Resultado es = ",centesal,decesal,unidsal," \n");               
            } 
            else {

                tx_232e("Error en los valores insertados \n");
            }

            contador = 0;
        }
    }             
    return;
}

//****  Funcion que envia una cadena de caracteres por el puerto serial *************************************************************************************************************************
void tx_232(char *mens,char *numero1,char *numero2,char *numero3,char *n){
    
    while (*mens!=0){
               
        TXREG1=*mens; //envio el caracter apuntado por el puntero
        PIR1bits.TXIF=0; //limpio bandera de transmision de dato
        while(!PIR1bits.TXIF); //espero a que se envie el byte
        
        mens++;        
    }
    
    if (cente!=0){
    while (*numero1!=0){
               
        TXREG1=*numero1; //envio el caracter apuntado por el puntero
        PIR1bits.TXIF=0; //limpio bandera de transmision de dato
        while(!PIR1bits.TXIF); //espero a que se envie el byte
        
        numero1++;
    }
    }
    
        while (*numero2=0){
               
        TXREG1=*numero2; //envio el caracter apuntado por el puntero
        PIR1bits.TXIF=0; //limpio bandera de transmision de dato
        while(!PIR1bits.TXIF); //espero a que se envie el byte
        
        numero2++;
    }
    
    while (*numero3!=0){
               
        TXREG1=*numero3; //envio el caracter apuntado por el puntero
        PIR1bits.TXIF=0; //limpio bandera de transmision de dato
        while(!PIR1bits.TXIF); //espero a que se envie el byte
        
        numero3++;
    }
    while (*n!=0){
               
        TXREG1=*n; //envio el caracter apuntado por el puntero
        PIR1bits.TXIF=0; //limpio bandera de transmision de dato
        while(!PIR1bits.TXIF); //espero a que se envie el byte
        
        n++;
    }
}

void tx_232e(char *mens){
    while (*mens!=0){
             
        TXREG1=*mens; //envio el caracter apuntado por el puntero
        PIR1bits.TXIF=0; //limpio bandera de transmision de dato
        while(!PIR1bits.TXIF); //espero a que se envie el byte
        
        mens++;        
    }
}