/*
 * File:   teclado_display_main.c
 * Author: MIGUEL PETRUZZELLA
 *
 * Created on 0 de marzo de 2023, 08:36 AM
 */


#include <xc.h>
#include <math.h>
#include<string.h>
#define _XTAL_FREQ 48000000    //defino frecuencia del oscilador para que el macro delay defina el retardo/*




__attribute__((address(0x1006))) const int firma[] = {0x600d}; //incluyo firma para que el bootloadre reconazca el programa de usuario
void tx_232(char *p,char); //prototipo de la funcion tx_232
void inicio(), primer_valor(), segundo_valor(),encender_leds();
int bandera1;
const char segmentos[]={0x24,0xc7,0xe5,0x74,0xf1,0xf3,0xa4,0xf7,0xf4,0xb7,0x40,0xd3,0x42,0x48, 0x2c, 0xcf, 0xed, 0x7c,0xf8,0xfb,0xac,0xff,0xfc,0xbf  };//0xc7
                      //--0---1----2----3----4----5----6----7-----8---9----10---11---12---13
                      //- 1---2----3-----4---5----6----7----8----9----0--   -  --E----r--  -.
int dis1;
int dis2;
int dis3;
int dis4;
int VAL;
char cambio1, SIG,REINICIO,ope;
int sumando1, sumando2, contador, resultado, resultadoabs;

#include "config.h"




//*****  funcion de ervicio de la interrrupcion de alta prioridad **********

void __interrupt(high_priority) hint(void)
{

  INTCONbits.INT0F=0;
  
return;
}

//*****  funcion de ervicio de la interrrupcion de baja prioridad **********
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
                    
                    LATA=segmentos[dis1];
                    cat1=1; // RE2 ON SW 12-11-10
                    cat2=0;
                    cat3=0;
                    cat4=0;
                    
                    
                  
                     //cargo el digito a mostrar en ese dislay
                    
                    //****** verifico el teclado fila 2
           
                    
                    if((PORTD & 0x0F)!=0) {
                        if (PORTDbits.RD3 == 1) {
                        VAL=3;
                        bandera1=bandera1+1;
                        
                        } 
                          if (PORTDbits.RD2 == 1) {
                        VAL=4;
                        bandera1=bandera1+1;
                        
                        } 
                          if (PORTDbits.RD1 == 1) {
                        VAL=5;
                        bandera1=bandera1+1;
                        
                        }
                        
                        if (PORTDbits.RD0 == 1) {
                        ope=4;
                        REINICIO=2;
                        contador=1;
                        __delay_ms(100);
                        
                        }
                       
                    }
                    
                    break;
                case 2: //activo el display 2
                    
                    cat1=0;
                    LATA=segmentos[dis2];
                    cat2=1; // RE1  
                    cat3=0;
                    cat4=0;
                
                    
                    
                    
                    //cargo el digito a mostrar en ese dislay
                    //****** verifico el teclado fila 3
                    
                    if((PORTD & 0x0F)!=0) {
                        if (PORTDbits.RD3 == 1) {
                        VAL=2;
                        bandera1++;
                        }
                        if (PORTDbits.RD2 == 1) {
                        VAL=1;
                        bandera1++;
                        } 
                          if (PORTDbits.RD1 == 1) {
                        VAL=0;
                        bandera1++;
                        }
                        if (PORTDbits.RD0 == 1) {
                        ope=8;
                        REINICIO=2;
                        contador=1;
                        __delay_ms(100);
                        }
                    }  
                    
                    break;
                case 3:  //activo el display 3
                    cat1=0;
                    cat2=0;
                    LATA=segmentos[dis3];
                    cat3=1;  //RE0
                    cat4=0;
                    
                   
                    //cargo el digito a mostrar en ese dislay
                    //****** verifico el teclado fila 4
                   
                if((PORTD & 0x0F)!=0) {       
                    if (PORTDbits.RD3 == 1) {
                        VAL=9;
                        bandera1++;
                    } 
                    
                    if (PORTDbits.RD0 == 1) {
                        SIG++;
                    if ((SIG % 2) == 0){
                        dis4=10;
                        __delay_ms(200);
                    }
                    else{
                        dis4=13;
                        __delay_ms(200);
                    }
                        
                        
                    }
                    if (PORTDbits.RD2 == 1) {
                        REINICIO=1;
                        
                    }
                    if (PORTDbits.RD1 == 1) {
                        contador++;
                        
                        
                    }
                    
                    
                    }
                    
                    
                    
                    break;
                
                case 4: //activo el display 4
                    cat1=0;
                    cat2=0;
                    cat3=0;
                    LATA=segmentos[dis4];
                    cat4=1;  //RC1
                    
   
              
                
                        if (PORTDbits.RD3 == 1) {
                        VAL=6;
                        bandera1=bandera1+1;
                        
                        } 
                        if (PORTDbits.RD2 == 1) {
                        VAL=7;
                        bandera1=bandera1+1;
                        
                        } 
                        if (PORTDbits.RD1 == 1) {
                        VAL=8;
                        bandera1=bandera1+1;
                        }
                         
                        if (PORTDbits.RD0 == 1) {
                        ope=1;
                        REINICIO=2;
                        contador=1;
                        __delay_ms(100);
                        
                        }
                    break;
                
            }
            
            if(bandera1==0 & cambio1==0){
             dis1=10;
             dis2=10;
             dis3=10;
             if((SIG % 2) == 0){
             dis4=10;
             }
             else{
                 dis4=13;
             }
             cambio1=1;
             __delay_ms(200);
            
        
                }
    
            if(bandera1==1 & cambio1==1 ){
            dis1=VAL;
            dis2=10;
            dis3=10;
            if((SIG % 2) == 0){
             dis4=10;
             }
             else{
                 dis4=13;
             }
            cambio1=0;
            __delay_ms(200);
            }
    
            if(bandera1==2 & cambio1==0 ){
                dis2=dis1;
                dis1=VAL;
                dis3=10;
            if((SIG % 2) == 0){
             dis4=10;
             }
             else{
                 dis4=13;
             }
                cambio1=1;
                __delay_ms(200);
            }
            if(bandera1==3 & cambio1==1){
                dis2=12;
                dis1=12;
                dis3=11;
                dis4=10;
                cambio1=0;
                __delay_ms(200);
            }
            
            if(REINICIO==1){
                REINICIO=0;
                SIG=0;
                bandera1=0;
                cambio1=0;
                ope=0;
                contador=0;
                dis1=10;
                dis2=10;
                dis3=10;
                dis4=10;
            __delay_ms(10);
            }
            
            //suma*********************************************************
            if(REINICIO==2 & ope==1 & contador==1){
                
            if(dis1==9){
                dis1=-1;
            } 
            if(dis2==9){
                dis2=-1;
            } 
                 
               if((SIG % 2) == 0){
                sumando1= (((dis2+1)*10)+(dis1+1));
                }
                else{
                 sumando1= -(((dis2+1)*10)+(dis1+1));
                } 
            
               REINICIO=0;
                SIG=0;
                bandera1=0;
                cambio1=0;
                dis1=10;
                dis2=10;
                dis3=10;
                dis4=10;
            __delay_ms(10);
            
            }
            
            
            
            if(ope==1 & contador==2){
              
            if(dis1==9){
                dis1=-1;
            } 
            if(dis2==9){
                dis2=-1;
            }
               
               if((SIG % 2) == 0){
                sumando2 = (((dis2+1)*10)+(dis1+1));
                }
                else{
                 sumando2 = -((((dis2+1)*10)+(dis1+1)));
                } 
            
               REINICIO=0;
                SIG=0;
                bandera1=1;
                cambio1=0;
                contador++;
                resultado= sumando1 + sumando2;
                resultadoabs= fabs(resultado);
                
                dis1 = ((resultadoabs % 10)-1); 
                if(dis1+1==0){
                    dis1=9;
                }
                
                dis2 = (((resultadoabs / 10) % 10)-1) ;
                if(dis2+1==0){
                    dis2=9;
                }
                
                dis3 =((resultadoabs/100)-1);
                if(dis3+1==0){
                    dis3=10;
                }
                
                if (resultado>=0){
                    dis4=10;
                }
                else{
                    dis4=13;
                }
                
            __delay_ms(10);
            
            }
            
            //resta*********************************************************
            if(REINICIO==2 & ope==4 & contador==1){
                
            if(dis1==9){
                dis1=-1;
            } 
            if(dis2==9){
                dis2=-1;
            } 
                 
               if((SIG % 2) == 0){
                sumando1= (((dis2+1)*10)+(dis1+1));
                }
                else{
                 sumando1= -(((dis2+1)*10)+(dis1+1));
                } 
            
               REINICIO=0;
                SIG=0;
                bandera1=0;
                cambio1=0;
                dis1=10;
                dis2=10;
                dis3=10;
                dis4=10;
            __delay_ms(10);
            
            }
            
            
            
            if(ope==4 & contador==2){
              
            if(dis1==9){
                dis1=-1;
            } 
            if(dis2==9){
                dis2=-1;
            }
               
               if((SIG % 2) == 0){
                sumando2 = (((dis2+1)*10)+(dis1+1));
                }
                else{
                 sumando2 = -((((dis2+1)*10)+(dis1+1)));
                } 
            
               REINICIO=0;
                SIG=0;
                bandera1=1;
                cambio1=0;
                contador++;
                resultado= sumando1 - sumando2;
                resultadoabs= fabs(resultado);
                
                dis1 = ((resultadoabs % 10)-1); 
                if(dis1+1==0){
                    dis1=9;
                }
                
                dis2 = (((resultadoabs / 10) % 10)-1) ;
                if(dis2+1==0){
                    dis2=10;
                }
                
                dis3 =((resultadoabs/100)-1);
                if(dis3+1==0){
                    dis3=10;
                }
                
                if (resultado>=0){
                    dis4=10;
                }
                else{
                    dis4=13;
                }
                
            __delay_ms(10);
            
            }
            //multiplicacion--------------
            if(REINICIO==2 & ope==8 & contador==1){
                
            if(dis1==9){
                dis1=-1;
            } 
            if(dis2==9){
                dis2=-1;
            } 
                 
               if((SIG % 2) == 0){
                sumando1= (((dis2+1)*10)+(dis1+1));
                }
                else{
                 sumando1= -(((dis2+1)*10)+(dis1+1));
                } 
            
               REINICIO=0;
                SIG=0;
                bandera1=0;
                cambio1=0;
                dis1=10;
                dis2=10;
                dis3=10;
                dis4=10;
            __delay_ms(10);
            
            }
            
            
            
            if(ope==8 & contador==2){
              
            if(dis1==9){
                dis1=-1;
            } 
            if(dis2==9){
                dis2=-1;
            }
               
               if((SIG % 2) == 0){
                sumando2 = (((dis2+1)*10)+(dis1+1));
                }
                else{
                 sumando2 = -((((dis2+1)*10)+(dis1+1)));
                } 
            
               REINICIO=0;
                SIG=0;
                bandera1=1;
                cambio1=0;
                contador++;
                resultado= sumando1 *sumando2;
                resultadoabs= fabs(resultado);
                
                dis1 = ((resultadoabs % 10)-1); 
                if(dis1+1==0){
                    dis1=9;
                }
                        
                dis2 = (((resultadoabs % 100) / 10)-1) ;
                if(dis2+1==0){
                    dis2=9;
                }
                     
                dis3 =(((resultadoabs % 1000 )/ 100) -1);
                if(dis3+1==0){
                    dis3=9;
                }
                
                dis4 =((resultadoabs / 1000) -1);
                if(dis4+1==0){
                    dis4=9;
                }
                
                if(resultado<0){
                    dis4=dis4+14;
                }
                
                
             
                
            __delay_ms(10);
            
            }
            
            
            
                      
        INTCONbits.TMR0IF=0;    //reactivo interrupcion
           
    
        }
    
    
    return;
}





void main(void) {
    config();
    SIG=0;
    bandera1=0;
    cambio1=0;
    contador=0;
    
while(1){
        
 
  
  }
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

