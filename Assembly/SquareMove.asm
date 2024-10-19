.ORG $8000

start:
    LDA #$1
    STA $0266
    LDY #$66 ; lowbyte, heightbyte is useless because it's always on the 2 page (screen)
    
    LDA #$00 ; counter
    STA $00 ; counter Lowbyte = 0

loop:
    LDX $4000
    TXA
    AND #%00001111 ; enable only the input
    BEQ next ; if there's no input go to next

    LDA $00
    CMP #$FF ; Speed
    BNE increment_counter ; if counter < FF, increment it
    
    JMP handle_direction ; if counter is FF, check for direction input

increment_counter:
    INC $00 ; Incrementa l'iteratore
    JMP next

handle_direction:
    TXA
    AND #%00000001
    BNE up
    
    TXA
    AND #%00000010
    BNE down
    
    TXA
    AND #%00000100
    BNE left
    
    TXA
    AND #%00001000
    BNE right
    
    JMP next

up:
    JSR clear_square
    TYA
    SEC ; Set carry = 1
    SBC #$10
    TAY
    JSR move_square
    RTS

down:
    JSR clear_square
    TYA
    CLC ; Clear carry
    ADC #$10
    TAY 
    JSR move_square
    RTS

left:
    JSR clear_square
    TYA
    SEC ; Set carry = 1
    SBC #$01
    TAY
    JSR move_square
    RTS

right:
    JSR clear_square
    TYA
    CLC ; Clear carry
    ADC #$01
    TAY
    JSR move_square
    RTS

move_square:
    LDA #$01
    STA $0200, Y
    RTS

clear_square:
    LDA #$00
    STA $0200, Y
    RTS

next:
    JMP loop

nmi:
    RTI

break:
    RTI

.goto $fffa
.DW nmi
.DW start
.DW break