.DB "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
; Variables
.ORG $8000

.define char_vel_x $0001
.define char_vel_y $0002

;;; Important Registers

; PPU

.define PPU_CTRL $2000
.define PPU_MASK $2001
.define PPU_STATUS $2002
.define OAM_ADDR $2003
.define OAM_DATA $2004
.define PPU_SCROLL $2005
.define PPU_ADDR $2006
.define PPU_DATA $2007
.define OAM_DMA  $4014

; CONTROLLER INPUT

.define JOY1 $4016

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


; Loading nametable
	lda PPU_STATUS 	; reading PPUSTATUS
	lda #$20	; writing 0x2000 in PPUADDR to write on PPU, the address for nametable 0
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	ldx #$00
	ldy #$00

nametable_loop:
	lda ($00), Y
	sta PPU_DATA
	iny
	cpy #$00
	bne nametable_loop
	inc $0001
	inx
	cpx #$04	; size of nametable 0: 0x0400
	bne nametable_loop

; Color setup for background
	lda PPU_STATUS
	lda #$3F	; writing 0x3F00, pallete RAM indexes
	sta PPU_ADDR
	lda #$00
	sta PPU_ADDR
	ldx #$00

; Sprites color setup
	lda PPU_STATUS
	lda #$3F
	sta PPU_ADDR
	lda #$10
	sta PPU_ADDR
	ldx #$00
sprite_color_loop:
    stx $04
	lda $04
	sta PPU_DATA
	inx
	cpx #$10
	bne sprite_color_loop

; Code for reseting scroll
	lda #$00
	sta PPU_SCROLL
	lda #$00
	sta PPU_SCROLL



main:
	; Turning on NMI and rendering
	lda #%10010000
	sta PPU_CTRL	; PPUCTRL
	lda #%00011010	; show background
	sta PPU_MASK	; PPUMASK, controls rendering of sprites and backgrounds

	lda #$01
	sta char_vel_x
; Reading input data

	lda #$01
	sta JOY1
	lda #$00
	sta JOY1

; Order: A B Select Start Up Down Left Right
; only one bit is read at a time, so we have to read JOY1 eight times

; A
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne A_not_pressed

A_not_pressed:

; B
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne B_not_pressed

B_not_pressed:

; Select
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Select_not_pressed

Select_not_pressed:

; Start
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Start_not_pressed

Start_not_pressed:

; Up
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Up_not_pressed

	dec char_vel_y

Up_not_pressed:

; Down
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Down_not_pressed

	inc char_vel_y

Down_not_pressed:

; Left
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Left_not_pressed
	
	dec char_vel_x

Left_not_pressed:

; Right
	lda JOY1
	and #%00000001
	cmp #%00000001
	bne Right_not_pressed

	inc char_vel_x

Right_not_pressed:

	jmp	main

nmi:

nmi_sprites:
	lda #$00
	sta OAM_ADDR
	lda #$02
	sta OAM_DMA

;; Draw character

	lda #$08      ; Top of the screen
	clc
	adc char_vel_y
  	sta $0200     ; Sprite 1 Y Position
  	lda #$08
	clc
	adc char_vel_y
  	sta $0204     ; Sprite 2 Y Position
  	lda #$10
	clc
	adc char_vel_y
  	sta $0208     ; Sprite 3 Y Position
  	lda #$10
	clc
	adc char_vel_y
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

	rti

irq:
    RTI

.goto $FFFA
.DW nmi         ; Vettore per l'NMI
.DW main        ; Vettore per il reset
.DW irq         ; Vettore per IRQ/BRK


.INCBIN "1.bin"
.INCBIN "2.bin"
