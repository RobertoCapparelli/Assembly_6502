.db "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.ORG $8000

; Define PPU registers
.define PPUCTRL $2000
.define PPUMASK $2001
.define PPUADDR $2006
.define PPUDATA $2007
.define PPSCROLL $2005
.define CONTROLLER1 $4016

; Define memory addresses for buttons and scrolling
.define buttons_addr $0020
.define scroll_x $0021

; Definire i dati della tilemap
Tilemap:
.db $00, $01, $02, $01, $04, $06, $02, $05  ; Definisci i valori della tilemap
;scroll_x: .db 0 <---- Why? 
; Inizializzare la tilemap nella VRAM

; Inizializzare la tilemap nella VRAM

main:
    LDA #%10001000
    STA PPUCTRL ;control register
    LDA #%00001000
    STA PPUMASK ;mask register
    
    JSR LoadTilemap          ; Chiama la subroutine per caricare la tilemap

    ; Imposta lo scrolling iniziale
    LDA #$00         ; Imposta lo scroll X a 0
    STA PPSCROLL     ; Scrivi il valore di scroll X
    LDA #$00         ; Imposta lo scroll Y a 0
    STA PPSCROLL     ; Scrivi il valore di scroll Y

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
    LDA #$03
    STA PPUDATA  
    
    ;Set Scroll from 00
    LDA #$00                  
    STA PPUADDR               
    LDA #$00                   
    STA PPUADDR              
    LDA #$10
    STA PPUDATA  
loop:
    JSR ReadButton        
    JMP loop     
              
LoadTilemap:
    LDX #$00 
    LDA #$24                  ; Indice per la tilemap
    STA PPUADDR               ; Resettare l'indirizzo PPU
    LDA #$00                   ; Indirizzo VRAM dove inizia la tilemap (0x2000 + 0x20)
    STA PPUADDR               ; Scrivere l'indirizzo basso

LoadTilemapLoop:
    LDA Tilemap, X            ; Carica il valore della tilemap
    STA PPUDATA               ; Scrivere il valore nella VRAM
    INX                       ; Incrementa l'indice
    CPX #$08                  ; Controlla se abbiamo caricato 8 tiles
    BNE LoadTilemapLoop       ; Se non abbiamo finito, ripetere

    RTS  
    
ReadButton:
    LDA #$01               
    STA CONTROLLER1        
    STA buttons_addr ; Clear buttons state
    LSR A            ; Shift the bits to the right
    STA CONTROLLER1      

ReadButtonLoop:
    LDA CONTROLLER1        
    LSR A                  
    ROL buttons_addr   ; Rotate the result into buttons_addr              
    BCC ReadButtonLoop ; If carry is clear, continue looping       

    LDA buttons_addr
    AND #%00000001     ; Check if the right button is pressed    
    BEQ SkipRight
    INC scroll_x           

SkipRight:
    LDA buttons_addr
    AND #%00000010         
    BEQ SkipLeft
    DEC scroll_x           

SkipLeft:
    JMP RTI

nmi:
    TAX 

    LDA scroll_x
    ;CMP #$FF               
    ;BCS limit_right
    ;BPL limit_left
    STA PPSCROLL           
    LDA #$00               
    STA PPSCROLL
    TXA
    RTI

limit_right:
    LDA #$FF
    STA PPSCROLL
    TXA
    JMP RTI

limit_left:
    LDA #$00
    STA PPSCROLL
    TXA
    JMP RTI

irq:
    RTI

RTI:  
    RTS

.goto $fffa

.DW nmi
.DW main
.DW irq

.INCBIN "1.bin"
.INCBIN "2.bin"
