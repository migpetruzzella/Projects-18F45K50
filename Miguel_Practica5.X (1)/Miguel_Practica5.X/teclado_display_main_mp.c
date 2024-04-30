/*
 * File:   teclado_display_main.c
 * Author: MIGUEL PETRUZZELLA
 *
 * Created on 0 de marzo de 2023, 08:36 AM
 */


#include <xc.h>
#include<string.h>
#define _XTAL_FREQ 48000000    //defino frecuencia del oscilador para que el macro delay defina el retardo/*



__attribute__((address(0x1006))) const int firma[] = {0x600d}; //incluyo firma para que el bootloadre reconazca el programa de usuario
void tx_232(char *p,char); //prototipo de la funcion tx_232
const char segmentos[]={0x24,0xc7,0xe5,0x74,0xf1,0xf3,0xa4,0xf7,0xf4,0xb7,0x40};//0xc7
const char mens1[]= "Pulsador RB0 activado \n";
#include "config.h"
#include "wiegand.h"





//*****  funcion de ervicio de la interrrupcion de alta prioridad **********

void __interrupt(high_priority) hint(void)
{
        char    rx_buf;
        if(INTCONbits.INT0F){ // verifico interrupcion externa en pin RB0
           // tx_232(mens1,1); //envio mens1 por puerto serial
            //__delay_ms(100);//retado de un segundo
            INTCONbits.INT0F=0; //reactivo interrucion
        }
        //******* seccion para interfaz wiegand *********************************************
    //*********************************************************************************
    if(INTCON3bits.INT1F){ // verifico interrupcion externa en pin RB0
           
        wuno();
            
            INTCON3bits.INT1F=0; //reactivo interrucion
            
        }
    //************************************************************************************
    if(INTCON3bits.INT2F){ // verifico interrupcion externa en pin RB0
            
        wcero();
            INTCON3bits.INT2F=0; //reactivo interrucion
        }
    //*************************************************************************************
    //******
       
        if(PIR1bits.RCIF){// verifico interrupcion por recepcion de puerto serial
        
             
            rx_buf=RCREG1;      //leo el byte recibido
            if(RCSTA1bits.OERR){ //verifio si hay error de overun y borro bandera de error
                RCSTAbits.CREN=0;
                RCSTAbits.CREN=1;
            }
            rx_buf++;
            TXREG1=rx_buf;  //reenvio el byte leido 
            PIR1bits.TXIF=0; //limpio bandera de transmision
            while(!PIR1bits.TXIF); //espero a que se envie el byte
            
            PIR1bits.RCIF=0;  //reactivo la interrupcion
        }
return;
}
char tecla;
//*****  funcion de ervicio de la interrrupcion de baja prioridad **********
void __interrupt(low_priority) lint(void)
{   
        char static rota;

        if(INTCONbits.TMR0IF){ // verifico interrupcion por TIMER 0
            //wig_tout();  //agrego para timeout de wiegand
            TMR0H=tm0_h;            //cargo constantes de retardo
            TMR0L=tm0_l;
            wig_tout();
            if (rota>=4)rota=1; //reiniciamos el contador de rotaciones
            else{
                
                rota++;
            }
            
            //**************** actalizacion del display cada 4 ms *****
            
            switch(rota){
                
                case 1: //activo el display 1
                    cat1=1;
                    cat2=0;
                    cat3=0;
                    cat4=0;
                    LATA=segmentos[tecla]; //cargo el digito a mostrar en ese dislay
                    //****** verifico el teclado fila 3
                    if ((PORTDbits.RD0==1)!=0){
                        
                        tecla=7;
                    }
                    if ((PORTDbits.RD1==1)!=0){
                        
                        tecla=6;
                    }
                    if ((PORTDbits.RD2==1)!=0){
                        
                        tecla=5;
                    }
                    if ((PORTDbits.RD3==1)!=0){
                        
                        tecla=4;
                    }
                    
                    break;
                case 2: //activo el display 2
                    cat1=0;
                    cat2=1;
                    cat3=0;
                    cat4=0;
                    LATA=segmentos[tecla]; //cargo el digito a mostrar en ese dislay
                    //****** verifico el teclado fila 2
                    if (PORTDbits.RD2==1){
                        
                        tecla=9;
                    }
                    if (PORTDbits.RD3==1){
                        
                        tecla=8;
                    }
                     if (PORTDbits.RD1==1 || PORTDbits.RD0==1){
                        
                        tecla=10;
                    }
                    
                    
                    
                    
                    break;
                case 3:  //activo el display 3
                    cat1=0;
                    cat2=0;
                    cat3=1;
                    cat4=0;
                    LATA=segmentos[tecla]; //cargo el digito a mostrar en ese dislay
                    //****** verifico el teclado fila 1
                    if (PORTDbits.RD1==1 || PORTDbits.RD0==1 || PORTDbits.RD3==1 || PORTDbits.RD2==1){
                        
                        tecla=10;
                    }
                    
                    break;
                case 4: //activo el display 4
                    cat1=0;
                    cat2=0;
                    cat3=0;
                    cat4=1;
                     LATA=segmentos[tecla]; //cargo el digito a mostrar en ese dislay
                    //****** verifico el teclado fila 4 1
                    if (PORTDbits.RD0==1 ){
                        
                        tecla=3;
                    }
                    if (PORTDbits.RD1==1 & 0x0F){
                        
                        tecla=2;
                    }
                    if (PORTDbits.RD2==1 & 0x0F){
                        
                        tecla=1;
                    }
                    if (PORTDbits.RD3==1 & 0x0F){
                        
                        tecla=0;
                    }
                     break; 
                
             
            }
            
            
            
            INTCONbits.TMR0IF=0;    //reactivo interrupcion
 
             
        }

return;
}




void main(void) {
    
    

     char retorno=0x41;  
     char *mens2="Prueba con ram \n";
    config(); // configuro puertos, interrupciones, oscilador y perifericos
    conf_wig();
   //tx_232(mens1); //envio mens1 por puerto serial
    
    retorno=reeprom(0x01);
    
   tx_232("Prueba EEPROM \n",15); //envio mens1 por puerto serial
   tx_232(&retorno,1);
   retorno++;
   weeprom(0x1,retorno);
    tecla=0;
    char b2,b1,b0;
    while(1){
        
        if(wiegand (&b2,&b1,&b0)){
            tx_232(&b2,1);
            tx_232(&b1,1);
            tx_232(&b0,1);
            tx_232("\n",1);
          
        }
        
                
            
        }
    
        
        
        
        
      
    return;
}
//****  Funcion que envia una cadena de caracteres por el perto serial ********
void tx_232(char *mens,char longitud){
    
   
        //while (*mens!=0){
        while (longitud>0){


            TXREG1=*mens; //envio el caracter apuntado por el puntero
            PIR1bits.TXIF=0; //limpio bandera de transmision de dato
            while(!PIR1bits.TXIF); //espero a que se envie el byte
            longitud--;
            mens++;
        } 
    
   
   
    
    
}
// funcion que permite escribir un byte en la eeprom interna ///
void weeprom(char dir, char dato){ //dir=direccion del dato   dat=dato a escribir 1 byte
   
INTCONbits.GIE=0; //desactivo la interrupcion
EEADR= dir; //cargo la direccion del byte a escribir
EEDATA=dato;  //cargo el dato a escribir
 
 EECON1bits.WREN=1; //habilito escritura en eeprom

 EECON2=0x55; //genero codigo de seguridad para escribir en eeprom
 EECON2=0xAA;

 EECON1bits.WR=1; //activo la escritura en eeprom
 while(EECON1bits.WR==1); //esepro hasta que se escriba el byte
EECON1bits.WREN=0; //desactivo escritura en eeprom
INTCONbits.GIE=1; //reactivo las interrupciones
 //return;
}
//funcion que permite leer un byte de la eeprom interna
char reeprom(char dir){ //dir = direccion del byte a leer
    
    EEADR=dir; //cargo la direccion a leer
    EECON1bits.EEPGD=0; 
    EECON1bits.CFGS=0;
    EEDATA=0;
    EECON1bits.RD= 1; //activo lectura de eeprom
    return EEDATA; //retorno el byte leido
}

