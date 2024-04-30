/*
 * File:   mainfinal.c
 * Author: migue
 *
 * Created on 4 de marzo de 2024, 03:27 PM
 */

#include <xc.h>
#include<string.h>
#include<stdio.h>
#define _XTAL_FREQ 48000000    //defino frecuencia del oscilador para que el macro delay defina el retardo/*



__attribute__((address(0x1006))) const int firma[] = {0x600d}; //incluyo firma para que el bootloadre reconazca el programa de usuario

void tx_232(char *); //prototipo de la funcion tx_232
void verificacion_ini();
void   cargar_ini();
void  verificacion();
void lectura_tarjeta();


const char segmentos[]={0x24,0xc7,0xe5,0x74,0xf1,0xf3,0xa4,0xf7,0xf4,0xb7,0x40,0xd3,0x42,0x48,0xf6,0xf7,0x93};//0xc7
                      //--0---1----2----3----4----5----6----7-----8---9----10---11---12---13---14---15---16
                      //- 1---2----3-----4---5----6----7----8----9----0--   -  --E----r--  -.---A---B----C


char codigo_leido[5]; 
char rx_buf;

char dis1;
char dis2;
char dis3;
char dis4;
int estado;
int contador_de_lectura=0; 
int contadordecarga=0;

int aux_de_carga_inicial;
char byte_de_verif;


void dis_abierto();
void dis_cerrado();

const char mens1[]= "Pulsador RB0 activado \n";
#include "config.h"
#include "wiegand.h"

char b2,b1,b0;
void permutacion_de_estados(int);
   


void __interrupt(high_priority) hint(void)
{
    
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
    
    
    
    
    
    
    
        if(PIR1bits.RCIF){// verifico interrupcion por recepcion de puerto serial
        
             
            rx_buf=RCREG1;      //leo el byte recibido
            if(RCSTA1bits.OERR){ //verifio si hay error de overun y borro bandera de error
                RCSTAbits.CREN=0;
                RCSTAbits.CREN=1;
            }
           
            TXREG1=rx_buf;  //reenvio el byte leido 
            PIR1bits.TXIF=0; //limpio bandera de transmision
            while(!PIR1bits.TXIF); //espero a que se envie el byte
            
            
            if (contador_de_lectura <= 5) {
            codigo_leido[contador_de_lectura]= rx_buf;
            contador_de_lectura++;
            }
            


            PIR1bits.RCIF=0;  //reactivo la interrupcion
        }
    
return;
}

void __interrupt(low_priority) lint(void){
  
  char static rota;

        if(INTCONbits.TMR0IF){ // verifico interrupcion por TIMER 0
            
            TMR0H=tm0_h;            //cargo constantes de retardo
            TMR0L=tm0_l;
    
            if (rota>=4)rota=1; //reiniciamos el contador de rotaciones
            else{
                
                rota++;
            }
          

            
            switch(rota){
                
            case 1: 
                    
                    LATA=dis1;
                    cat1=1; // RE2 ON SW 12-11-10
                    cat2=0;
                    cat3=0;
                    cat4=0;
                                  
                    break;
                case 2: //activo el display 2
                    
                    cat1=0;
                    LATA=dis2;
                    cat2=1; // RE1  
                    cat3=0;
                    cat4=0;
                
               
                    break;
                case 3:  //activo el display 3
                    cat1=0;
                    cat2=0;
                    LATA=dis3;
                    cat3=1;  //RE0
                    cat4=0; 
                    
                    break;
                
                case 4: //activo el display 4
                    cat1=0;
                    cat2=0;
                    cat3=0;
                    LATA=dis4;
                    cat4=1;  //RC1
              
                    break;
            }
            INTCONbits.TMR0IF=0;  
        }
  return; 
}



void main(void) {
    config();
    conf_wig();
    
    tx_232("Bienvenidos \n");
    tx_232("Verificando sistema \n");
   
    /*
    weeprom(01,0xff);
    weeprom(02,0xff);
    weeprom(03,0xff);
    
    weeprom(04,0xff);
    weeprom(05,0xff);
    weeprom(06,0xff);
    */
    verificacion_ini();
    
    if(aux_de_carga_inicial==1){
        cargar_ini();
    }
    
    while(1){
    
        verificacion();
        lectura_tarjeta();
        
    }
    
    
    
    while(1);
    
    return;
}

void verificacion_ini(){
    if(reeprom(0x01)==0xff && reeprom(0x04)==0xff ){
        estado=1;         
        aux_de_carga_inicial=1;
        dis_abierto();      
        tx_232("Desarmado \n");  
    }
    else {             
        estado=0;
        aux_de_carga_inicial=0;
        dis_cerrado();      
        tx_232("Armado \n");  
    }
    return;
}


void tx_232(char *mens){
    
    while (*mens != 0){
        
        TXREG1=*mens; //envio el caracter apuntado por el puntero
        PIR1bits.TXIF=0; //limpio bandera de transmision de dato
        while(!PIR1bits.TXIF); //espero a que se envie el byte
        
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

    
    
void dis_abierto(){
    
    dis1=segmentos[12];
     dis2=segmentos[11];
     dis3=segmentos[15];
     dis4=segmentos[14];
     PORTBbits.RB4 = 0;
    
} 

void dis_cerrado(){  
     dis1=segmentos[12];
     dis2=segmentos[11];
     dis3=segmentos[11];
     dis4=segmentos[16];
     PORTBbits.RB4 = 1;
     
} 

 void cargar_ini(){
    tx_232("carga los codigos porfa \n");
    
    while(contadordecarga<2){
    verificacion();
    }
    
    tx_232("codigos cargados bien \n");
    tx_232("se procede a cerrar \n");
    dis_cerrado();
    estado=0;
    aux_de_carga_inicial=0;
    
    return;
    
 
 }
 
 void verificacion(){
     
     if(contador_de_lectura>5){     //si ya se recibieron 5 datos por el puerto
            contador_de_lectura=0;
            
            byte_de_verif=(codigo_leido[0]+codigo_leido[1]+codigo_leido[2]+codigo_leido[3]+codigo_leido[4])&0xFF;

            if(byte_de_verif==codigo_leido[5] && estado==1 && codigo_leido[0]== 01){     //veo si la suma es igual al byte chk        
                weeprom(codigo_leido[0],codigo_leido[1]);            //almaceno dato en la EEPROM
                weeprom(codigo_leido[0]+0x01,codigo_leido[2]);
                weeprom(codigo_leido[0]+0x02,codigo_leido[3]);
                tx_232("Ok \n"); //envío Ok por el puerto para confirmar dato correcto
                contadordecarga++;
                
            }else{
                if(byte_de_verif==codigo_leido[5] && estado==1 && codigo_leido[0]== 02){     //veo si la suma es igual al byte chk        
                weeprom(codigo_leido[0]+0x02,codigo_leido[1]);            //almaceno dato en la EEPROM
                weeprom(codigo_leido[0]+0x03,codigo_leido[2]);
                weeprom(codigo_leido[0]+0x04,codigo_leido[3]);
                tx_232("ok \n");  //envío Ok por el puerto para confirmar dato correcto
                contadordecarga++;
                }
            else{ 
                tx_232("Error. \n"); //envío Error por el puerto para informar de dato incorrecto
                if (estado==1) tx_232("Valor incorrecto \n");
                if (estado==0) tx_232("sistema cerrado no se puede cargar codigo \n");
            }}
     }
     
     return;
 }
 
 void lectura_tarjeta(){
 
     if(wiegand (&b2,&b1,&b0)){
         /*   
         tx_232(&b2);
            tx_232(&b1);
            tx_232(&b0);
            tx_232("\n");
           
         */
      
         
     if ((reeprom(0x01)==b2 && reeprom(0x02)==b1 && reeprom(0x03)==b0) ||
         (reeprom(0x04)==b2 && reeprom(0x05)==b1 && reeprom(0x06)==b0)){
         
     
        permutacion_de_estados(estado);
     }
     
     
     }
     
    
     
     return;
 }
 
 void permutacion_de_estados(int estados){
     
     if(estados==0){
         estado=1;
        dis_abierto();
        tx_232("abriendo  sistema \n");
     }else{
        estado=0;
        dis_cerrado();
        tx_232("cerrando  sistema \n");
     }
     return;
 }