#include p18f458.inc
	config WDT = OFF
	config PWRT = OFF 
	ORG 0X0
	
FR1	EQU 0x20
FR2	EQU 0x21
; product result
S0	EQU 0x22
S1	EQU 0x23
S2	EQU 0x24
S3	EQU 0x25
ZL	EQU 0x26
ZH	EQU 0x27
YL	EQU 0x28
YH	EQU 0x29
LH	EQU 0x2A
LL	EQU 0x2B
KH	EQU 0x2C
KL	EQU 0x2D
C1	EQU 0x2E
C2	EQU 0x2F
C3	EQU 0x30	
	
K1	EQU 0x83
K2	EQU 0x03
	


	    ;Port input outout
	    BCF TRISB, 0    ;for trig pulse
	    BSF TRISB, 4    ;input from echo
	    BCF TRISC, 0 
	    ;Timer 0, 1 and 2 configuration
	    MOVLW   0x0
	    MOVWF   T2CON
	    MOVWF   T1CON
	    MOVWF   T0CON
	    MOVLW   0x19 ;10 micro second
	    MOVWF   PR2
	    
	    

	    
START	 CALL TRIG_PULSE ;10 micro second
	    ;CALL TRIG_PULSE2	
	    
	    CALL TIME_ECHO ;sonar process
	    
	    ;Calculating distance
	    MOVFF TMR0H, FR2
	    MOVFF TMR0L, FR1
	    CALL MULTI
	    
	    ;displaying results
	    CALL DISPLAY 
	    
	    CALL DELAY_10MS
	    ;CALL DEL_10MS_M2

	    GOTO START

	    ;Send 10 microS trigger on port B using timer 2
	    
TRIG_PULSE  BCF PIR1, TMR2IF
	    BSF PORTB, 0
	    BSF T2CON, TMR2ON
LOOP	    BTFSS   PIR1, TMR2IF
	    BRA LOOP
	    BCF PORTB, 0
	    RETURN
	    
	    
	    
	    ;Send 10 microS trigger on port B using instruction delay
	    
	    
TRIG_PULSE2 MOVLW 0x08	
	    MOVWF C3	
	    BSF PORTB, 0
AGAIN	    DECF C3	
	    BNZ AGAIN	
	    BCF PORTB, 0
	    RETURN
	    
	    
	    ;Measure (propagation + echo) time  using timer 0
	    ;till port A become zero again
TIME_ECHO   MOVLW 0x0
	    MOVWF TMR0H
	    MOVWF TMR0L
	    
LOOP1	    BTFSS PORTB, 4
	    BRA LOOP1
	    BSF T0CON, TMR0ON
LOOP2	    BTFSC PORTB, 4
	    BRA LOOP2
	    CALL TRIG_PULSE
	    BCF T0CON, TMR0ON
	    RETURN
	    
	    
	    ;a * b = c : 16bit * 16bit = 32 bits
	    ;prameter FR1, FR2 (represent a)
	    ;b = 0.01372
	    ;return S0, S1, S2 and S3 (represent c)
	    ;approved
MULTI	    CLRF S0
	    CLRF S1
	    CLRF S2
	    CLRF S3
	    MOVF FR1,0          
	    MULLW K1           
	    MOVFF PRODH,ZH     
	    MOVFF PRODL,ZL
	    MOVF FR2,0      
	    MULLW K1       
	    MOVFF PRODH,YH
	    MOVFF PRODL ,YL
	    MOVF FR1,0    
	    MULLW  K2        
	    MOVFF PRODH,LH
	    MOVFF PRODL,LL
	    MOVF FR2,0    
	    MULLW K2    
	    MOVFF PRODH,KH
	    MOVFF PRODL,KL
	    MOVFF ZL,S0
	    MOVF ZH,0        
	    ADDWF YL ,0      
	    BTFSC STATUS,C
	    INCF S2,1
	    ADDWF LL,0     
	    BTFSC STATUS ,C 
	    INCF S2,1
	    MOVWF S1 
	    MOVF YH,0    
	    ADDWF S2,1   
	    BTFSC  STATUS,C
	    INCF S3,1
	    MOVF LH,0
	    ADDWF S2,1
	    BTFSC STATUS,C
	    INCF S3,1
	    MOVF KL,0
	    ADDWF S2,1
	    BTFSC STATUS,C
	    INCF S3,1
	    MOVF KH,0
	    ADDWF S3,1 
	    RETURN
	    
	    ;approved
	    
	    
	    
DISPLAY	    MOVLW 02 
	    CPFSLT S3 
	    BRA OFF 
	    BSF PORTC,0
	    BRA SKIP
OFF	    BCF PORTC ,0
SKIP	    RETURN

	    
	    
	    ;delay between two detections for 10 ms
	    ;using timer 1
	    
	    
DELAY_10MS  MOVLW 0x9E
	    MOVWF TMR1H
	    MOVLW 0x58
	    MOVWF TMR1L
	    BSF T1CON,	TMR1ON
LOOP3	    BTFSS PIR1, TMR1IF
	    BRA LOOP3
	    BCF T1CON, TMR1ON
	    RETURN
	    
	    ;delay between two detections for 10 ms
	    ;using instructions delay
	    
	    
DEL_10MS_M2 MOVLW 0x64	
	    MOVWF C1	
AGAIN1	    MOVLW 0x52	
	    MOVWF C2						
AGAIN2	    DECF C2, F			
	    BNZ AGAIN2	
	    DECF C1, F	
	    BNZ AGAIN1	
	    RETURN
	    
TO_END	    MOVLW 0x60
	    END
	    