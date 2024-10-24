.ORG $8000

start:
CLI
LDA #$11
LDX #$22
LDY #$33

BRK

loop:
    JSR hello
    LDX $4000
    TXA
    AND #%00001100 ; left + right %00001111 & %00001100 = %00001100
    CMP #%00001100 ; match ?
    BEQ left_and_right
    TXA ; bit0: up; bit1: down; bit2: left; bit3: right; bit4: space; %00000010 & %00000001 = %00000000
    AND #%00000001 ;
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
black:
    LDA #0
    STA $200
    JMP next
up:
    LDA #$01
    STA $200
    JMP next
down:
    LDA #$02
    STA $200
    JMP next
left:
    LDA #$03
    STA $200
    JMP next
right:
    LDA #$04
    STA $200
    JMP next
left_and_right:
    LDA #$05
    STA $200
    JMP next
next:
    JMP loop

hello:
    ; preamble
    STA $FD
    STX $FE
    STY $FF
    ; function body
    LDA #$bb
    LDX #$cc
    LDY #$dd
    ; postamble
    LDY $FF
    LDX $FE
    LDA $FD
    RTS


nmi:
    LDX #$44
    RTI

break:
    LDX #$55
    RTI

.goto $fffa
.DW nmi
.DW start
.DW break
