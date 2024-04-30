/* 
 * File:   Practica_4_JhoswerDelgado
 * Author: Jhoswer Delgado
 * C.I:    25.444.785
 * Created on 10 de enero de 2024, 02:09 PM
 */

#include <xc.h>
#include  "config.h"

void config(){
    
        // configuracion del oscilador
    
        OSCCON=0x70;	//ajusto el oscilador para trabajar a 48MHZ	
			
		OSCCON2=0x10;   //ajusto el oscilador para trabajar a 48MHZ	
		OSCTUNE=0x80;   //ajusto el oscilador interno para trabajar en la frecuencia de calibracion de fabrica	
    
    
    
    //****** configuracion de puertos paralelos
    
    TRISAbits.RA0=0; //defino el bit 0 del puerto A como salida 
    
    TRISAbits.RA1=0; //defino el bit 0 del puerto A como salida 
    
    TRISBbits.RB0=1;  //defino el bit 0 del puerto B como entrada
    
    TRISCbits.RC7=1; //puero de entrada para recepcion serial
    
    TRISCbits.RC6=0; //puertos de salida para transmision serial
    
    ANSELC=0;
    
    //configuracion de interrupciones
    
    INTCON=0;               // me aseguo de limpiar INTCON
    RCONbits.IPEN=1;        // activo opcion de interrupcion con prioridad
    INTCONbits.INT0E=1;     // habilito interrupcion externa en RB0
    INTCON2bits.INTEDG0=0;  // Indico interrupcion por falnco de bajada
    INTCONbits.GIEL=1;      // Activo intrrupcion debaja prioridad
    PIE1bits.RCIE=1;        //activo interrupcion por recepcion de usart
    IPR1bits.RCIP=1;        //asigno prioridad alta para recepcion por puerto serie

    // configuracion del usart
    
    SPBRG1 = 0x26;          //velocidad de comunicacion 19200 baudios
    SPBRGH1 = 0;
    TXSTA1bits.TX9=0;       //transmision de 8 bits
    TXSTA1bits.TXEN=1;      //activo transmsion
    TXSTA1bits.SYNC=0;      //modo asincronico
    RCSTA1bits.RX9=0;       // modo de recepcion de 8 bits
    RCSTA1bits.CREN=1;      //habilito recepcion continua
    BAUDCON1=0x40;
    RCSTA1bits.SPEN=1;      //activo puerto serial
    
}
