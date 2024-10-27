.db "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.org $8000

.define PPUCTRL $2000
.define PPUMASK $2001
.define PPUADDR $2006
.define PPUDATA $2007
.define PPSCROLL $2005

main:
    LDA #%10001000
    STA PPUCTRL
    LDA #%00001000
    STA PPUMASK
    
    ; Writing to palette color
    LDA #$3f
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    LDA #$2C
    STA PPUDATA
    LDA #$23
    STA PPUDATA
    LDA #$39
    STA PPUDATA
    LDA #$17
    STA PPUDATA
    
    ; Writing to nametable
    LDA #$24
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    LDA #$01
    STA PPUDATA
    
    
loop:

    JMP loop

nmi:
    TAX
    LDA #$3f
    STA PPUADDR
    LDA #$03
    STA PPUADDR
    LDA $00
    ADC #$01
    STA $00
    STA PPUDATA
    
    ; Scrolling
    LDA $01
    ADC #$01
    STA $01
    STA PPSCROLL ; X
    STA PPSCROLL ; Y
    TXA
    RTI
    
irq:
    RTI

.goto $fffa

.DW nmi
.DW main
.DW irq

.INCBIN "mario_right.bin"
.INCBIN "mario_left.bin"
