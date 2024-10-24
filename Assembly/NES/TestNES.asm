.DB "NES", $1A, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.ORG $8000

main:
    JMP main


nmi:
    RTI
    
irq:
    RTI

.goto $fffa

.DW nmi
.DW main
.DW irq