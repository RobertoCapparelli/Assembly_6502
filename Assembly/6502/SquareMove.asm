.ORG $8000

start:
    LDA #$1
    STA $0266
    LDY #$66 ; lowbyte, heightbyte is useless because it's always on the 2 page (screen)
    
    LDA #$00 ; counter
    STA $00 ; counter Lowbyte = 0

loop:
    LDA $00
    CMP #$FF ; Speed
    BNE increment_counter
    ; if counter < FF, increment it

    LDX $4000
    TXA
    AND #%00001111 ; enable only the input
    BEQ change_color ; if there's no input go to next

    JMP handle_direction ; check for direction input
    
change_color:
    LDA #$01
    STA $0200, Y
    JMP next

increment_counter:
    INC $00 
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
    JSR clear_square_and_reset_counter
    TYA
    SEC ; Set carry = 1
    SBC #$10
    TAY
    JSR move_square
    JMP next

down:
    JSR clear_square_and_reset_counter
    TYA
    CLC ; Clear carry
    ADC #$10
    TAY 
    JSR move_square
    JMP next

left:
    JSR clear_square_and_reset_counter
    TYA
    AND #%00001111   ; REMEMBER!!! Lowbyte for column, Heightbyte for line
    CMP #$00         
    BEQ at_left_edge ; if Y < 00 -> at left Edge 
    DEY
    JSR move_square
    JMP next
    
at_left_edge:
    TYA
    AND #%11110000   ; Get current line
    ORA #%00001111   ; Move to $0F  (X0000 become X1111)
    TAY
    JSR move_square
    JMP next

at_right_edge:
    TYA
    AND #%11110000   ; Same for Left
    ORA #%00000000   
    TAY
    JSR move_square
    JMP next
    
right:
    JSR clear_square_and_reset_counter
    TYA
    AND #%00001111   
    CMP #$0F         
    BEQ at_right_edge
    INY
    JSR move_square
    JMP next
    
move_square:
    LDA #$03
    STA $0200, Y
    RTS

clear_square_and_reset_counter:
    LDA #$00
    STA $0200, Y
    STA $00
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