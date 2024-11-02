.db "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.org $8000

.define PPUCTRL $2000
.define PPUMASK $2001
.define PPUADDR $2006
.define PPUDATA $2007
.define PPSCROLL $2005

;Variables
.define char_vel_x $0001
.define char_vel_y $0002
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
	bne clear_memory
main:
    LDA #%10001000
    STA PPUCTRL
    LDA #%00011010
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
	adc char_vel_x
  	sta $0203     ; Sprite 1 X Position
  	lda #$10
	clc
  	adc char_vel_x
	sta $0207     ; Sprite 2 X Position
  	lda #$08
	clc
  	adc char_vel_x
	sta $020B     ; Sprite 3 X Position
 	lda #$10
	clc
  	adc char_vel_x
	sta $020F     ; Sprite 4 X Position

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

.INCBIN "1.bin"
.INCBIN "2.bin"
