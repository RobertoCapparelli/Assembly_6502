.DB "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.ORG $8000      ; Inizio della PRG-ROM

;Variables
.define char_vel_x $0001
.define char_vel_y $0002
.define posY $0023
.define IsMoved $0021
.define jumpCounter $0024

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
;INPUT
.define CONTROLLER1 $4016
.define buttons_addr $0020



reset:
	SEI			; disable IRQs
	CLD			; disable decimal mode
;	ldx #$40
;	stx $4017	; disable APU frame IRQ
	LDX #$FF
	TXS			; set up stack
	INX			; now X = 0
	LDA PPU_STATUS
	LDX #%00000000
	STX	PPU_CTRL	; disable NMI
	LDX #%00000000
	STX PPU_MASK	; disable rendering
;	stx $4010	; disable DMC IRQs

	LDA PPU_STATUS	; PPU warm up
vblankwait1:	; First wait for vblank to make sure PPU is ready
	BIT PPU_STATUS	; PPU status register
	BPL vblankwait1

vblankwait2:
	bit PPU_STATUS
	bpl vblankwait2

	LDA #$00
	LDX #$00
	STA char_vel_x
	STA char_vel_y
	STA posY
	STA buttons_addr
	STA CONTROLLER1
	
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
	JSR ApplyGravity
	JSR ReadButton  
    JMP loop        ; Ciclo infinito
	
ApplyGravity:
	LDA jumpCounter
    BEQ CheckGround       ; Se jumpCounter è zero, procedi con la gravità
	JMP next
CheckGround:
    LDA posY
    CMP #$B0               ; Soglia per il terreno (adatta secondo le necessità)
    BCS GravityDisabled     ; Se Y >= $F0, disabilita la gravità (sprite è a terra)

	LDA IsMoved             ; Controlla se lo sprite si è già mosso
    CMP #$01
    BEQ next     ; Salta l'aggiornamento se `IsMoved` è già impostato
	
    ; Applicazione della gravità
    LDA char_vel_y
    CLC
    ADC #$01                ; Incrementa la velocità Y per simulare la gravità
    STA char_vel_y          ; Salva la nuova velocità Y
	
	 ; Aggiungi la velocità Y a posY
    LDA posY
    CLC
    ADC char_vel_y
    STA posY
	
	LDA #$01
    STA IsMoved 
	JMP next    
	            ; Salta alla fine per evitare l'azzeramento di char_vel_y
GravityDisabled: 
	LDA #$00
	STA char_vel_y
	
next:
	RTS
	
	; With shifting buttons_addr = FF, TODO: Try to understand why
;ReadButton:
;    LDA #$01               
;    STA CONTROLLER1 
;	LDA #$00
;	STA CONTROLLER1 
;    STA buttons_addr  
;
; ReadButtonLoop:
;    LDA CONTROLLER1        
;    LSR A                  
;    ROL buttons_addr   ; Rotate the result into buttons_addr              
;    BCC ReadButtonLoop ; If carry is clear, continue looping 

 	ReadButton:
     LDA #$01                ; Imposta il latch a 1 per catturare lo stato del controller
     STA CONTROLLER1 
     LDA #$00                ; Rilascia il latch impostando a 0
     STA CONTROLLER1 
     LDA #$00
     STA buttons_addr        ; Inizializza buttons_addr a 0
 
     LDY #$08                ; Imposta il contatore per leggere 8 bit
 ReadButtonLoop:
     LDA CONTROLLER1         ; Legge lo stato del controller
     LSR A                   ; Sposta il bit più a destra nel carry
     ROL buttons_addr        ; Ruota il carry in buttons_addr
     DEY                     ; Decrementa il contatore
     BNE ReadButtonLoop      ; Continua il loop finché Y non è 0
 
 	LDA buttons_addr
    CMP #$00
    BEQ NoButtonPressed
	
	LDA IsMoved             ; Controlla se lo sprite si è già mosso
    CMP #$01
    BEQ NoButtonPressed     ; Salta l'aggiornamento se `IsMoved` è già impostato

; RIGHT
    LDA buttons_addr
    AND #%00000001          ; Controlla se il pulsante "Right" è premuto (bit 0)
    BEQ SkipRight	
    INC char_vel_x 
	LDA #$01
    STA IsMoved         ; Imposta a 1 per evitare incremento continuo
SkipRight:

; LEFT
    LDA buttons_addr
    AND #%00000010          ; Controlla se il pulsante "Left" è premuto (bit 1)
    BEQ SkipLeft
    DEC char_vel_x  
	LDA #$01
    STA IsMoved        ; Imposta a -1 per evitare decremento continuo
SkipLeft:


;; UP
	LDA buttons_addr
	AND #%00001000         ; Controlla se il pulsante "Up" è premuto (bit 3)
	BEQ SkipUp
	LDA #$10               ; Imposta il contatore di salto a 3 cicli
	STA jumpCounter
	LDA #$F0               ; Valore negativo per un impulso verso l'alto
	STA char_vel_y         ; Imposta la velocità verticale per il salto
	
	; Modifica immediata di posY
	LDA posY
	CLC                    ; Clear Carry per l'addizione
	ADC char_vel_y         ; Aggiungi la velocità Y negativa per simulare il salto
	STA posY               ; Aggiorna posY
	
	LDA #$01
	STA IsMoved            ; Imposta IsMoved per evitare ulteriori movimenti nello stesso ciclo

SkipUp:
    
NoButtonPressed:

    RTS                     ; Ritorna al loop principale
	
nmi:
	TAX
	
    nmi_sprites:
	lda #$00
	sta OAM_ADDR
	lda #$02
	STA OAM_DMA
	
    LDA jumpCounter
    BEQ SkipDecrement  ; Se jumpCounter è uguale a zero, salta il decremento
    DEC jumpCounter    ; Decrementa jumpCounter se è maggiore di zero
SkipDecrement:
	
;; Draw character

	LDA #$08      ; Top of the screen
	clc
	adc posY
  	sta $0200     ; Sprite 1 Y Position
  	lda #$08
	clc
	adc posY
  	sta $0204     ; Sprite 2 Y Position
  	lda #$10
	clc
	adc posY
  	sta $0208     ; Sprite 3 Y Position
  	lda #$10
	clc
	adc posY
  	sta $020C     ; Sprite 4 Y Position
	
	LDA #$08      ; Left of the screen.
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
	STA $020F     ; Sprite 4 X Position

  	LDA #$3A      ; Top Left section of Mario standing still
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

  	
	
	; Resetta IsMoved alla fine del VBLANK
    LDA #$00
    STA IsMoved
	TXA
    RTI

irq:
    RTI

.goto $FFFA
.DW nmi         ; Vettore per l'NMI
.DW main        ; Vettore per il reset
.DW irq         ; Vettore per IRQ/BRK

.INCBIN "2.bin"
.INCBIN "1.bin"