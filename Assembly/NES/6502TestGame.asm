.DB "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.ORG $8000      ; Inizio della PRG-ROM

;Variables
.define char_vel_x $0001
.define char_vel_y $0002
.define char_speed $0003
.define posY $0023
.define IsMoved $0021
.define isMovedTimer $0028
.define jumpCounter $0024
.define jumpTriggered $0025 
.define gravityTimer $0027   ; Variabile per il timer della gravità
.define screenX $0030
.define screenLimit $0029
.define animCounter $0031

.define sprite2_posX $0040  ; Posizione X del nuovo sprite
.define sprite2_posY $0041

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
	STA jumpCounter
	STA posY
	STA buttons_addr
	STA jumpTriggered
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
    
	LDA #$10
	STA posY

	LDA #$02
	STA char_speed
	
	LDA #$F0         ; Posizione iniziale X (vicino al bordo destro)
    STA sprite2_posX
    LDA #$40         ; Posizione iniziale Y
    STA sprite2_posY

	LDA #$00
	STA screenX
	STA char_vel_x
	
	; Imposta il limite inizia	le per il movimento dello sprite
	LDA #$C0      ; Valore scelto per indicare la posizione limite
	STA screenLimit

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

        ; Ritorna alla routine principale
	
ApplyGravity:
	LDA gravityTimer         ; Carica il valore del timer
    CMP #$02                 ; Controlla se il timer ha raggiunto il valore desiderato (es. 10 per applicare la gravità ogni 10 NMI)
    BNE next          ; Se non ha raggiunto il valore, salta l'applicazione della gravità

	LDA #$00                 ; Resetta il timer
    STA gravityTimer
	
    LDA jumpTriggered
    CMP #$01       ; Se jumpTriggered è zero, procedi con la gravità
	BEQ next
		
CheckGround:
    LDA posY
    CMP #$B0              ; Soglia per il terreno
    BCS GravityDisabled   ; Se Y >= soglia, ferma la gravità

    ; Applica la gravità normalmente
    LDA char_vel_y
    CLC ;Flag 0
    ADC #$01              ; Incrementa la velocità Y per simulare la gravità
    STA char_vel_y
    LDA posY
    CLC
    ADC char_vel_y        ; Aggiorna posY
    STA posY
    RTS

GravityDisabled:
    LDA #$00
    STA char_vel_y        ; Ferma la gravità
	LDA #$B0
	STA posY
    RTS
	
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
    BEQ nextJump     ; Salta l'aggiornamento se `IsMoved` è già impostato

; RIGHT
    LDA buttons_addr
    AND #%00000001          ; Controlla se il pulsante "Right" è premuto (bit 0)
    BEQ SkipRight

	LDA char_vel_x 
    CMP screenLimit         ; Controlla se char_vel_x ha raggiunto il limite
    BCC MoveSpriteRight     ; Se char_vel_x < screenLimit, muovi lo sprite

    ; Se char_vel_x >= screenLimit, aggiorna solo lo scroll e non muovere lo sprite
    INC screenX
    JMP SkipRight           ; Salta l'incremento di char_vel_x

MoveSpriteRight:
    ; Muovi lo sprite se non ha raggiunto il limite
    INC char_vel_x
    INC char_vel_x          ; Incrementa la velocità per spostarlo più velocemente (adatta secondo necessità)

SkipRight:
    LDA #$01
    STA IsMoved
	             ; Imposta IsMoved per evitare incrementi continui

; LEFT
    LDA buttons_addr
    AND #%00000010          ; Controlla se il pulsante "Left" è premuto (bit 1)
    BEQ SkipLeft
    DEC char_vel_x 
	DEC char_vel_x  
	LDA #$01
    STA IsMoved        ; Imposta a -1 per evitare decremento continuo
SkipLeft:


; Se il tasto "UP" è premuto e il salto non è già stato attivato
	LDA buttons_addr
    AND #%00001000         ; Controlla se il pulsante "Up" è premuto (bit 3)
    BEQ ResetJumpFlag      ; Se il tasto non è premuto, resetta il flag e termina

    LDA jumpTriggered
    CMP #$01               ; Controlla se il salto è già attivato
    BEQ nextJump    ; Se jumpTriggered è 1 (salto già attivato), salta l'inizio del ciclo

    ; Inizio del salto
    LDA #$F5               ; Valore negativo per l'impulso verso l'alto
    STA char_vel_y
    LDA #$01
    STA jumpTriggered      ; Imposta il flag per indicare che il salto è stato attivato
	
	LDA posY               ; Carica posY nell'accumulatore
    CLC                    ; Clear Carry per preparare l'addizione
    ADC char_vel_y         ; Somma il valore negativo di char_vel_y a posY
    STA posY  
	
    LDA #$01
    STA IsMoved            ; Imposta IsMoved per evitare ulteriori movimenti nello stesso ciclo

    ;LDA #$F0               ; Continua a decrementare la velocità Y per il salto
    ;STA char_vel_y           ; Salva il risultato in posY 
    RTS

ResetJumpFlag:
    ; Se il tasto "UP" non è premuto, resetta il flag
    LDA #$00
    STA jumpTriggered
    
NoButtonPressed:
    LDA #$00
    STA jumpTriggered
nextJump:
    RTS                    ; Ritorna al loop principale
nmi:
	TAX
	

	INC gravityTimer
	INC isMovedTimer
	 ; Controlla se il timer ha raggiunto la soglia per resettare `IsMoved`
    LDA isMovedTimer
    CMP #$02                ; Adatta questo valore in base alla frequenza desiderata
    BNE SkipResetIsMoved

    LDA #$00                ; Resetta `IsMoved` e il timer
    STA IsMoved
    STA isMovedTimer

SkipResetIsMoved:

  ; Aggiorna lo scroll orizzontale solo se necessario
    LDA screenX
    CMP #$00
    BEQ SkipScrollUpdate    ; Salta se screenX non è cambiato
    STA PPU_SCROLL
    LDA #$00
    STA PPU_SCROLL

SkipScrollUpdate:

    nmi_sprites:
	lda #$00
	sta OAM_ADDR
	lda #$02
	STA OAM_DMA

 ;   ; Se jumpCounter è maggiore di zero, applica l'impulso verso l'alto e decrementa
 ;   LDA jumpCounter
 ;   BEQ SkipDecrement  ; Se jumpCounter è zero, salta l'impulso
 ;   DEC jumpCounter    ; Decrementa jumpCounter
 ;   LDA char_vel_y
 ;   CLC
 ;   ADC #$01           ; Riduce progressivamente l'impulso
 ;   STA char_vel_y
	
	
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
	
    LDA sprite2_posX
    SEC               ; Imposta il carry per la sottrazione
    SBC #$01          ; Sottrai 1 per muovere a sinistra
    STA sprite2_posX
          
	 ; Disegna il nuovo sprite nella posizione aggiornata
    LDA sprite2_posY
    STA $0210         ; Sprite 5 Y Position
    LDA sprite2_posX
    STA $0213         ; Sprite 5 X Position

    LDA #$AA          ; Tile number per il nuovo sprite (es. un tile specifico)
    STA $0211         ; Sprite 5 Tile Number
    LDA #$00          ; No attributi speciali (es. senza flip)
    STA $0212         ; Sprite 5 Attributes

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