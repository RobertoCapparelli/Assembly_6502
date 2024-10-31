.DB "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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

;SPRITE
.define SPRITE_Y       $20       ; Posizione Y dello sprite
.define SPRITE_X       $50       ; Posizione X dello sprite
.define SPRITE_TILE    $00       ; Indice del tile da usare
.define SPRITE_ATTR    %00000100       ; Usa la palette 1, senza flipping

.define OAMADDR $2003
.define OAMDATA $2004

sprite1:
    ; Bitplane basso
    .byte %11111111  ; riga 1
    .byte %11111111  ; riga 2
    .byte %11111111  ; riga 3
    .byte %11111111  ; riga 4
    .byte %11111111  ; riga 5
    .byte %11111111  ; riga 6
    .byte %11111111  ; riga 7
    .byte %11111111  ; riga 8

    ; Bitplane alto (varia i bit per includere più colori)
    .byte %11111111  ; riga 1
    .byte %11111111  ; riga 2
    .byte %11111111  ; riga 3 (usa un colore diverso)
    .byte %11111111  ; riga 4 (usa un colore diverso)
    .byte %11111111  ; riga 5 (usa un colore diverso)
    .byte %11111111  ; riga 6
    .byte %11111111  ; riga 7
    .byte %11111111  ; riga 8

main:
    JSR WaitForVBlank   ; Attendi il VBlank prima di iniziare

    LDA #%10001000 ; Abilita gli sprite e seleziona il pattern table per gli sprite
    STA PPUCTRL
    LDA #%00011000 ; Abilita gli sprite e lo sfondo
    STA PPUMASK
     ; Scrivi i dati della palette
    JSR WritePalette
    JSR LoadSpritePattern ; Carica i dati dello sprite nella Pattern Table
    ; Carica lo sprite nell'OAM
    JSR LoadSprite
    
loop:
    JSR ReadButton        
    JMP loop 
      
WaitForVBlank:
    BIT $2002           
    BPL WaitForVBlank   
    RTS  
     
WritePalette:
    LDA #$3F          ; Indirizzo base della palette PPU
    STA PPUADDR
    LDA #$10          ; Posizione iniziale per gli sprite
    STA PPUADDR

    ; Palette 0 per sprite
    LDA #$0F          ; Trasparente
    STA PPUDATA
    LDA #$21          ; Colore principale
    STA PPUDATA
    LDA #$15          ; Colore secondario
    STA PPUDATA
    LDA #$0F          ; Colore di contorno
    STA PPUDATA

    ; Palette 1 per sprite
    LDA #$0F          ; Trasparente
    STA PPUDATA
    LDA #$22          ; Colore principale
    STA PPUDATA
    LDA #$16          ; Colore secondario
    STA PPUDATA
    LDA #$0F          ; Colore di contorno
    STA PPUDATA

    ; Palette 2 per sprite
    LDA #$0F          ; Trasparente
    STA PPUDATA
    LDA #$23          ; Colore principale
    STA PPUDATA
    LDA #$17          ; Colore secondario
    STA PPUDATA
    LDA #$0F          ; Colore di contorno
    STA PPUDATA

    ; Palette 3 per sprite (che userai con %00000100)
    LDA #$0F          ; Trasparente
    STA PPUDATA
    LDA #$24          ; Colore principale
    STA PPUDATA
    LDA #$18          ; Colore secondario
    STA PPUDATA
    LDA #$0F          ; Colore di contorno
    STA PPUDATA

    ; Continua per le sub-palette necessarie
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
    ;INC scroll_x           

SkipRight:
    LDA buttons_addr
    AND #%00000010         
    BEQ SkipLeft
    ;DEC scroll_x           

SkipLeft:
    JMP RTI

LoadSprite:
    LDA #$00          ; Inizializza l'indirizzo OAM a 0
    STA OAMADDR       ; Imposta l'OAMADDR all'inizio
    
    ; Posizione verticale (Y)
    LDA #SPRITE_Y
    STA OAMDATA

    ; Indice del tile
    LDA #SPRITE_TILE
    STA OAMDATA

    ; Attributi dello sprite
    LDA #SPRITE_ATTR
    STA OAMDATA

    ; Posizione orizzontale (X)
    LDA #SPRITE_X
    STA OAMDATA

    RTS
    
LoadSpritePattern:
    ; Setta l’indirizzo della Pattern Table nella PPU (ad esempio $0000)
    LDA #$04
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    ; Carica i dati del primo piano dello sprite
    LDX #$00
LoadSpriteDataLoop:
    LDA sprite1, X      ; Carica un byte da `sprite1`
    STA PPUDATA         ; Memorizza nella Pattern Table PPU
    INX
    CPX #$10            ; Continua finché non sono caricati 16 byte
    BNE LoadSpriteDataLoop
    RTS
    
nmi:
    TAX 
     ; Imposta OAMADDR a 0 per iniziare a scrivere nell'OAM dall'inizio
    LDA #$00
    STA OAMADDR

    ; Carica i dati dello sprite nell'OAM
    JSR LoadSprite
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

