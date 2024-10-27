.DB "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.ORG $8000          ; Inizio del programma

; Definizione di indirizzi
.define CONTROLLER1 $4016
var_value: .db 0   ; Variabile per memorizzare il valore

start:
    ; Inizializza il valore
    LDA #$00        ; Carica 0 in A
    STA var_value   ; Salva in var_value

main_loop:
    ; Invia il segnale di latch per il controller
    LDA #$01
    STA CONTROLLER1
    LDA #$00
    STA CONTROLLER1

    ; Inizializza il contatore per la lettura dei pulsanti
    LDX #$08

ReadButtonLoop:
    LDA CONTROLLER1      ; Leggi lo stato del controller
    LSR A                ; Sposta il bit nel carry
    ROL var_value        ; Ruota il carry nel registro var_value
    DEX                   ; Decrementa il contatore
    BNE ReadButtonLoop    ; Continua fino a che X non è 0

    ; Controlla il valore dei pulsanti
    LDA var_value        ; Leggi il valore di var_value
    AND #$04             ; Controlla se il pulsante Sinistra è premuto (bit 2)
    BEQ SkipLeft         ; Salta se non è premuto
    DEC var_value        ; Decrementa var_value se il pulsante Sinistra è premuto

SkipLeft:
    LDA var_value        ; Leggi di nuovo
    AND #$08             ; Controlla se il pulsante Destra è premuto (bit 3)
    BEQ SkipRight        ; Salta se non è premuto
    INC var_value        ; Incrementa var_value se il pulsante Destra è premuto

SkipRight:
    ; Qui puoi aggiungere codice per visualizzare o controllare var_value
    JMP main_loop        ; Torna al loop principale

.nmi:
    RTI                  ; Routine di NMI

.goto $fffa            ; Imposta i vettori di interrupt
.DW .nmi               ; Vettore NMI
.DW start              ; Vettore RESET