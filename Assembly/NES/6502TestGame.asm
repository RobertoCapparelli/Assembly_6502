.DB "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .ORG $8000      ; Inizio della PRG-ROM


;PPU
.define PPU_CTRL   $2000
.define PPU_MASK   $2001
.define PPU_STATUS $2002
.define OAM_ADDR   $2003
.define OAM_DATA   $2004
.define PPU_SCROLL $2005
.define PPU_ADDR   $2006
.define PPU_DATA   $2007
.define OAM_DMA    $4014
reset:
	sei			; disable IRQs
	cld			; disable decimal mode
;	ldx #$40
;	stx $4017	; disable APU frame IRQ
	ldx #$FF
	txs			; set up stack
	inx			; now X = 0
	lda PPU_STATUS
	ldx #%00000000
	stx	PPU_CTRL	; disable NMI
	ldx #%00000000
	stx PPU_MASK	; disable rendering
;	stx $4010	; disable DMC IRQs

	lda PPU_STATUS	; PPU warm up
vblankwait1:	; First wait for vblank to make sure PPU is ready
	bit PPU_STATUS	; PPU status register
	bpl vblankwait1

vblankwait2:
	bit PPU_STATUS
	bpl vblankwait2

	lda #$00
	ldx #$00
clear_memory:
	sta $0000, X
	sta $0100, X
	sta $0200, X
	sta $0300, X
	sta $0400, X
	sta $0500, X
	sta $0600, X
	sta $0700, X
	inx
	cpx #$00
	BNE clear_memory
    
main:
    LDA #%10001000
    STA PPU_CTRL
    LDA #%00011010
    STA PPU_MASK
    
    JSR load_palette ; Carica la palette delle sprite


     ; Writing to nametable
    LDA #$24
    STA PPU_ADDR
    LDA #$00
    STA PPU_ADDR
    LDA #$01
    STA PPU_DATA
    

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
    lda #$00
	sta OAM_ADDR
	lda #$02
	sta OAM_DMA

    lda #$08      ; Top of the screen
	clc
	;adc char_vel_y
  	sta $0200     ; Sprite 1 Y Position
  	lda #$08
	clc
	;adc char_vel_y
  	sta $0204     ; Sprite 2 Y Position
  	lda #$10
	clc
	;adc char_vel_y
  	sta $0208     ; Sprite 3 Y Position
  	lda #$10
	clc
	;adc char_vel_y
  	sta $020C     ; Sprite 4 Y Position

    lda #$3A      ; Top Left section of Mario standing still
  	sta $0201     ; Sprite 1 Tile Number
  	lda #$37      ; Top Right section of Mario standing still
 	sta $0205     ; Sprite 2 Tile Number
  	lda #$4F      ; Bottom Left section of Mario standing still
  	sta $0209     ; Sprite 3 Tile Number
  	lda #$4F      ; Bottom Right section of Mario standing still
  	sta $020D     ; Sprite 4 Tile Number
  	lda #$00		; No attributes, using first sprite palette which is number 0
  	sta $0202     ; Sprite 1 Attributes
  	sta $0206     ; Sprite 2 Attributes
  	sta $020A     ; Sprite 3 Attributes
  	lda #$40      ; Flip horizontal attribute
  	sta $020E     ; Sprite 4 Attributes

      	lda #$08      ; Left of the screen.
	clc
	;adc char_vel_x
  	sta $0203     ; Sprite 1 X Position
  	lda #$10
	clc
  	;adc char_vel_x
	sta $0207     ; Sprite 2 X Position
  	lda #$08
	clc
  	;adc char_vel_x
	sta $020B     ; Sprite 3 X Position
 	lda #$10
	clc
  	;adc char_vel_x
	sta $020F     ; Sprite 4 X Position

    ; Scrolling
    LDA $01
    ADC #$01
    STA $01
    STA PPU_SCROLL ; X
    LDA #$00
    STA PPU_SCROLL ; Y
    TXA
    RTI

irq:
    RTI

    .goto $FFFA
    .DW nmi         ; Vettore per l'NMI
    .DW main        ; Vettore per il reset
    .DW irq         ; Vettore per IRQ/BRK

.INCBIN "1.bin"
.INCBIN "2.bin"