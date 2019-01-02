;;; Some instructions ;;;;;
; LDX: load x
; STX: store x
; SEI: set interrupt disable
; CLD: clear decimal
; TXS: transfer X to stack pointer
;;;


.segment "HEADER"
	.byte 	"NES", $1A
	.byte 	2
	.byte	1
	.byte 	$01, $00

.segment "STARTUP"


.segment "CODE"

reset:
	sei			; disable IRQs
	cld			; disable decimal mode
;	ldx #$40
;	stx $4017	; disable APU frame IRQ
	ldx #$FF
	txs			; set up stack
	inx			; now X = 0
	lda $2002
	ldx #%00000000
	stx	$2000	; disable NMI
	ldx #%00000000
	stx $2001	; disable rendering
;	stx $4010	; disable DMC IRQs

	lda $2002	; PPU warm up
vblankwait1:	; First wait for vblank to make sure PPU is ready
	bit $2002	; PPU status register
	bpl vblankwait1

vblankwait2:
	bit $2002
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
	lda $2002 	; reading PPUSTATUS
	lda #$20	; writing 0x2000 in PPUADDR to write on PPU, the address for nametable 0
	sta $2006
	lda #$00
	sta $2006
	lda #<background_nametable	; saving nametable in RAM
	sta $0000
	lda #>background_nametable
	sta $0001
	ldx #$00
	ldy #$00

nametable_loop:
	lda ($00), Y
	sta $2007
	iny
	cpy #$00
	bne nametable_loop
	inc $0001
	inx
	cpx #$04	; size of nametable 0: 0x0400
	bne nametable_loop

; Color setup for background
	lda $2002
	lda #$3F	; writing 0x3F00, pallete RAM indexes
	sta $2006
	lda #$00
	sta $2006
	ldx #$00

color_loop:
	lda background_pallete, X
	sta $2007
	inx
	cpx #$10	; size of pallete RAM: 0x0020, until 0x3F10 is background palletes
	bne color_loop	; after 0x3F10, there should be sprite palletes

; Code for reseting scroll
	lda #$00
	sta $2005
	lda #$00
	sta $2005

; Turning on NMI and rendering
	lda #%00010000
	sta $2000	; PPUCTRL
	lda #%00001010	; show background
	sta $2001	; PPUMASK, controls rendering of sprites and backgrounds

forever:
	jmp	forever

nmi:
	rti

irq:
	rti

background_nametable:
	.incbin "bag.nam"

background_pallete:
	.incbin "bag.pal"

.segment "VECTORS"
	.word nmi		; when non-maskable interrupt happens, goes to label nmi
	.word reset		; when the processor first turns on or is reset, goes to reset
	.word irq		; using external interrupt IRQ

.segment "CHARS"
	.incbin "mario.chr"	; includes 8KB graphics
