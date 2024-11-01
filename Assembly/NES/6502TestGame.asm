.db "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .ORG $8000      ; Inizio della PRG-ROM

main:
    SEI
    CLD
    LDX #$FF
    TXS
    INX

    ; Inizializzazione della PPU
    LDA #$00
    STA $2000       ; PPUCTRL: disabilita rendering
    STA $2001       ; PPUMASK: disabilita rendering

    JSR load_palette ; Carica la palette delle sprite

    LDA #$00        ; Posizione Y della sprite
    STA $0200       ; OAM byte 0
    LDA #$02        ; Indice del tile (secondo tile definito in sprite_pattern)
    STA $0201       ; OAM byte 1
    LDA #$01        ; Attributi della sprite
    STA $0202       ; OAM byte 2
    LDA #$00        ; Posizione X della sprite
    STA $0203       ; OAM byte 3

    LDA #$08        ; Abilita rendering sprite e sfondo
    STA $2001

    JMP loop

load_palette:
    LDX #$3F       ; Inizia con X a 0
    STX $2006       ; Scrive l'alto byte dell'indirizzo PPU ($3F10)
    LDA #$3F
    STA $2006       ; Scrive il basso byte dell'indirizzo PPU ($3F10)

    LDA #$0F        ; Colore di trasparenza (sfondo)
    STA $2007       ; Scrive il colore nella memoria PPU
    LDA #$30        ; Primo colore della sprite (es. rosso)
    STA $2007
    LDA #$27        ; Secondo colore della sprite (es. verde)
    STA $2007
    LDA #$22        ; Terzo colore della sprite (es. blu)
    STA $2007
    LDA #$0F        ; Colore di trasparenza (di nuovo)
    STA $2007

    RTS             ; Ritorna dalla subroutine
    
loop:
    JMP loop        ; Ciclo infinito

nmi:
    TAX
    LDA #$00        ; Carica l'indirizzo di partenza (basso byte) per OAM DMA
    STA $2003       ; Imposta l'indirizzo di inizio OAM

    LDA #$02        ; Imposta la pagina di memoria ($0200) da copiare nella OAM
    STA $4014       ; Attiva il DMA per caricare le informazioni delle sprite
    TXA

    RTI

irq:
    RTI

    .goto $FFFA
    .DW nmi         ; Vettore per l'NMI
    .DW main        ; Vettore per il reset
    .DW irq         ; Vettore per IRQ/BRK

    ; Inserisci i dati grafici nella CHR-ROM
    .ORG $0000
sprite_pattern:
    .DB %00000000   ; Riga 1
    .DB %00000000
    .DB %00000000   ; Riga 2
    .DB %00000000
    .DB %00000000   ; Riga 3
    .DB %00000000
    .DB %00000000   ; Riga 4
    .DB %00000000
    .DB %00000000   ; Riga 5
    .DB %00000000
    .DB %00000000   ; Riga 6
    .DB %00000000
    .DB %00000000   ; Riga 7
    .DB %00000000
    .DB %00000000   ; Riga 8
    .DB %00000000
    
    sprite_pattern2:
   ; Riga 1 (tutta accesa, parte superiore del bordo)
    .DB %11111111   ; Bit plane 1
    .DB %00000000   ; Bit plane 2
    
    ; Riga 2 (bordi ai lati)
    .DB %10000001   ; Bit plane 1
    .DB %00000001   ; Bit plane 2
    
    ; Riga 3 (bordi ai lati)
    .DB %10000001   ; Bit plane 1
    .DB %00000001   ; Bit plane 2
    
    ; Riga 4 (bordi ai lati)
    .DB %10000001   ; Bit plane 1
    .DB %00000001   ; Bit plane 2
    
    .DB %10000001   ; Bit plane 1
    .DB %00000001   ; Bit plane 2
    
    ; Riga 6 (bordi ai lati)
    .DB %10000001   ; Bit plane 1
    .DB %00000001  ; Bit plane 2
    
    ; Riga 7 (bordi ai lati)
    .DB %10000001   ; Bit plane 1
    .DB %00000001  ; Bit plane 2
    
    ; Riga 8 (bordo inferiore)
    .DB %11111111   ; Bit plane 1
    .DB %00000000  ; Bit plane 2