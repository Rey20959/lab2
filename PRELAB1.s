;Universidad del Valle
;Juan Emilio Reyes 
;20959
;Jose Morales   
;Programación de microcontroladores
;Lab2
    
    
    
    
    
    
#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

PSECT udata_bank0 ;common memory
  cont_small: DS 1 ; 1 byte
  cont_big: DS 1
    
PSECT resVect, class=CODE, abs, delta=2
;--------vector reset------------
ORG 00h  ;posición 0000h para el reset
resetVec:
    PAGESEL main
    goto main
 
PSECT code, delta=2, abs
ORG 100h  
 
 ; posición para el código 
 ; -------configuración---------
main: 
    call config_io
    call config_reloj
    banksel PORTA
    banksel PORTC
    banksel PORTD
   
 ;--------loop principal------------
 loop: 
    btfsc PORTB, 0
    call inc_porta
    btfsc PORTB, 1
    call dec_porta
    btfsc PORTB, 2
    call inc_portd
    btfsc PORTB, 3
    call dec_portd
    btfsc PORTB, 4
    call sum_cont
    goto loop	; loop forever
    
;-------sub rutinas---------
config_io:
    bsf STATUS, 5 ;banco 11
    bsf STATUS, 6
    clrf ANSEL ; pines digitales
    clrf ANSELH 
    
    bsf STATUS, 5 ; banco 01
    bcf STATUS, 6
    clrf TRISA ; port A como salida 
    clrf TRISC ;portc output
    clrf TRISD; port D como salida
    ;Entradas
    bsf TRISB, 0
    bsf TRISB, 1
    bsf TRISB, 2
    bsf TRISB, 3
    bsf TRISB, 4
   
    
    bcf STATUS, 5 ;banco 00
    bcf STATUS, 6
    clrf PORTA 
    clrf PORTC
    clrf PORTD
    return
    
config_reloj:
    banksel OSCCON
    bcf IRCF2 ; OSCCON, 6 (0) 1MHz
    bcf IRCF1  ;          (0)
    bsf IRCF0 ;           (1)
    bsf SCS ; reloj interno
    return
    
inc_porta: 
    btfsc PORTB, 0
    goto $-1
    incf PORTA
    btfsc PORTA, 4
    clrf PORTA
    return
    
dec_porta: 
    btfsc PORTB, 1
    goto $-1
    decf PORTA
    call cont
    return

cont:
    bcf PORTA, 4
    bcf PORTA, 5
    bcf PORTA, 6
    bcf PORTA, 7
    return

inc_portd: 
    btfsc PORTB, 2
    goto $-1
    incf PORTD
    btfsc PORTD, 4
    clrf PORTD
    return
    
dec_portd:
    btfsc PORTB, 3
    goto $-1
    decf PORTD
    call cont2
    return
    
cont2:
    bcf PORTD, 4
    bcf PORTD, 5
    bcf PORTD, 6
    bcf PORTD, 7
    return

sum_cont:
    btfsc PORTB, 4
    clrw
    movf PORTA, w
    addwf PORTD, w
    movwf PORTC
    btfsc PORTC,5
    clrf PORTC
    return


END